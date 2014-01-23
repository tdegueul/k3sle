package fr.inria.diverse.k3.sle.jvmmodel

import fr.inria.diverse.k3.sle.k3sle.ModelRoot
import fr.inria.diverse.k3.sle.k3sle.MetamodelDecl
import fr.inria.diverse.k3.sle.k3sle.ModelTypeDecl
import fr.inria.diverse.k3.sle.k3sle.TransformationDecl

import fr.inria.diverse.k3.sle.lib.ModelUtils
import fr.inria.diverse.k3.sle.lib.ModelTypeException
import fr.inria.diverse.k3.sle.lib.GenericAdapter
import fr.inria.diverse.k3.sle.lib.AdapterFactory
import fr.inria.diverse.k3.sle.lib.ModelType
import fr.inria.diverse.k3.sle.lib.IFactory
import fr.inria.diverse.k3.sle.lib.EObjectAdapter

import org.eclipse.emf.common.util.EList

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource

import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.common.types.JvmTypeReference
import org.eclipse.xtext.common.types.TypesFactory

import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder

import java.util.List
import java.util.Map
import java.util.HashMap

import java.io.PrintWriter
import java.io.FileWriter
import java.io.BufferedWriter

import static extension fr.inria.diverse.k3.sle.jvmmodel.K3SLEJvmModelInferrerHelper.*

import com.google.inject.Inject

class K3SLEJvmModelInferrer extends AbstractModelInferrer
{
	@Inject extension JvmTypesBuilder
	@Inject extension IQualifiedNameProvider
	
	Map<String, Pair<ModelTypeDecl, EPackage>> registeredMTs
	Map<String, EPackage> effectivePkgs
	static final val DEBUG_FILE = "/tmp/k3sle.debug"

	def dispatch void infer(ModelRoot root, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
		registeredMTs = new HashMap<String, Pair<ModelTypeDecl, EPackage>>
		effectivePkgs = new HashMap<String, EPackage>
		
		if (!isPreIndexingPhase) {
			root.elements.filter(ModelTypeDecl).forEach[infer(acceptor, isPreIndexingPhase)]
			root.elements.filter(MetamodelDecl).forEach[infer(acceptor, isPreIndexingPhase)]
			root.elements.filter(TransformationDecl).forEach[infer(acceptor, isPreIndexingPhase)]
		}
	}
	
	def dispatch void infer(MetamodelDecl mm, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
		// !!!
		log("Infering MM " + mm.name)
		val pkg = mm.pkg		
		val adapSwitch = new StringBuilder
		
		pkg.weaveAspects(mm)
		
		registeredMTs
			.filter[name, definition | pkg.subtypeOf(definition.value)]
			.forEach[name, definition |
				val superType = definition.key 
				val superPkg  = definition.value
				
				acceptor.accept(mm.toClass(mm.adapterNameFor(superType, mm.name)))
					.initializeLater[
						superTypes += newTypeRef(superType.fullyQualifiedName.normalize.toString)
						superTypes += newTypeRef(GenericAdapter, newTypeRef(Resource))
						
						members += mm.toConstructor[
							parameters += mm.toParameter("adaptee", newTypeRef(Resource))
							body = '''super(adaptee) ;'''
						]
						
						members += mm.toMethod("getContents", newTypeRef(List, newTypeRef(Object)))[
							// !!!
							body = '''
								java.util.List<java.lang.Object> ret = new java.util.ArrayList<java.lang.Object>() ;
								for (org.eclipse.emf.ecore.EObject o : adaptee.getContents()) {
									«pkg.root.fullyQualifiedName.toString» wrap = («pkg.root.fullyQualifiedName.toString») o ;
									ret.add(new «mm.adapterNameFor(superType, pkg.root.name)»(wrap)) ;
								}
								return ret ;
							'''
						]
						
						members += mm.toMethod("getFactory", newTypeRef(superType.fullyQualifiedName.append(superPkg.factoryName).normalize.toString))[
							body = '''
								return new «mm.adapterNameFor(superType, mm.factoryName)»() ;
							'''
						]
					]
				
				superPkg.EClassifiers.filter(EClass).forEach[cls |
					val inCls = pkg.EClassifiers.filter(EClass).findFirst[it.name == cls.name]
					
					acceptor.accept(mm.toClass(mm.adapterNameFor(superType, inCls.name)))
						.initializeLater[
							superTypes += newTypeRef(GenericAdapter, newTypeRef(inCls.fullyQualifiedName.toString))
							superTypes += newTypeRef(superType.interfaceNameFor(inCls.name))
							
							members += mm.toConstructor[
								parameters += mm.toParameter("adaptee", newTypeRef(inCls.fullyQualifiedName.toString))
								body = '''super(adaptee) ;'''
							]
							
							cls.EAllAttributes.forEach[attr |
								val baseType =
									if (attr.EAttributeType != null)
										newTypeRef(attr.EAttributeType.instanceClassName)
									else
										newTypeRef(superType.interfaceNameFor(attr.EType.name))
								
								val returnType = if (attr.many) newTypeRef(List, baseType) else	baseType
								
								members += attr.toMethod(attr.getterName, returnType)[
									body = '''return adaptee.«attr.getterName»() ;'''
								]
								
								if (!attr.many)
									members += attr.toMethod(attr.setterName, newTypeRef(Void::TYPE))[
										parameters += attr.toParameter("o", baseType)
										body = '''adaptee.«attr.setterName»(o) ;'''
									]
							]
							
							cls.EAllReferences.forEach[ref |
								val inRef = inCls.EReferences.findFirst[it.name == ref.name]
								val intName = superType.interfaceNameFor(ref.EReferenceType.name)
								val adapName = mm.adapterNameFor(superType, ref.EReferenceType.name)
								val baseType = newTypeRef(intName)
									
								if (ref.many)
									members += ref.toMethod(ref.getterName, newTypeRef(List, baseType))[
										body = '''
											return new fr.inria.diverse.k3.sle.lib.ListAdapter<
												«intName»,
												«inRef.EReferenceType.fullyQualifiedName.toString»,
												«adapName»>(adaptee.«ref.getterName»(), new «adapName»Factory()
											) ;
										'''
									]
								else {
									members += ref.toMethod(ref.getterName, baseType)[
											body = '''return new «adapName»(adaptee.«ref.getterName»()) ;'''
										]
									members += ref.toMethod(ref.setterName, newTypeRef(Void::TYPE))[
											parameters += ref.toParameter("o", newTypeRef(intName))
											body = '''
												«adapName» wrap = («adapName») o ;
												adaptee.«ref.setterName»(wrap.getAdaptee()) ;
											'''
										]
								}
							]
							
							mm.aspects
								// !!!
								.filter[type.declaredOperations.filter[op | !op.simpleName.startsWith("priv")].forall[parameters.head.parameterType.simpleName == cls.name]]
								.forEach[asp |
									asp.type.declaredOperations
										.filter[op | !op.simpleName.startsWith("priv") && !op.simpleName.startsWith("super_")]
										.filter[op | !members.exists[opp | opp.simpleName == op.simpleName]]
										.forEach[op |
											members += mm.toMethod(op.simpleName, newTypeRef(op.returnType.qualifiedName))[
												val other = pkg.EClassifiers.filter(EClass).findFirst[ccls | ccls.name == op.returnType.simpleName]
												val paramsList = new StringBuilder
												
												if (other != null)
													returnType = newTypeRef(superType.interfaceNameFor(other.name))
												
												op.parameters.forEach[p, i |
													if (i > 0) {
														val otherr = pkg.EClassifiers.filter(EClass).findFirst[ccls | ccls.name == p.parameterType.simpleName]
														
														if (otherr != null) {
															paramsList.append(''', ((«mm.adapterNameFor(superType, otherr.name)») «p.simpleName»).getAdaptee() ''')
															parameters += mm.toParameter(p.simpleName, newTypeRef(superType.interfaceNameFor(otherr.name)))
														} else {
															paramsList.append(''', «p.simpleName» ''')
															parameters += mm.toParameter(p.simpleName, p.parameterType)
														}
													}
												]
												
												body = '''
													«IF other != null»
													return new «mm.adapterNameFor(superType, other.name)»(«asp.type.fullyQualifiedName».«op.simpleName»(adaptee«paramsList»)) ;
													«ELSE»
													«IF returnType.simpleName != "void"»return «ENDIF»«asp.type.fullyQualifiedName».«op.simpleName»(adaptee«paramsList») ;
													«ENDIF»
												'''
											]
										]
								]
							
							if (mm.superMetamodels.size > 0) {
								// !!!
								val superMM = mm.superMetamodels.head
								
								superMM.aspects
									// !!!
									.filter[type.declaredOperations.filter[op | !op.simpleName.startsWith("priv")].forall[parameters.head.parameterType.simpleName == cls.name]]
									.forEach[asp |
										asp.type.declaredOperations
											.filter[op | !op.simpleName.startsWith("priv") && !op.simpleName.startsWith("super_")]
											.filter[op | !members.exists[opp | opp.simpleName == op.simpleName]]
											.forEach[op |
												members += mm.toMethod(op.simpleName, newTypeRef(op.returnType.qualifiedName))[
													val other = pkg.EClassifiers.filter(EClass).findFirst[ccls | ccls.name == op.returnType.simpleName]
													val paramsList = new StringBuilder
													
													if (other != null)
														returnType = newTypeRef(superType.interfaceNameFor(other.name))
													
													op.parameters.forEach[p, i |
														if (i > 0) {
															val otherr = pkg.EClassifiers.filter(EClass).findFirst[ccls | ccls.name == p.parameterType.simpleName]
															
															if (otherr != null) {
																paramsList.append(''', ((«mm.adapterNameFor(superType, otherr.name)») «p.simpleName»).getAdaptee() ''')
																parameters += mm.toParameter(p.simpleName, newTypeRef(superType.interfaceNameFor(otherr.name)))
															} else {
																paramsList.append(''', «p.simpleName» ''')
																parameters += mm.toParameter(p.simpleName, p.parameterType)
															}
														}
													]
													
													body = '''
														«IF other != null»
														return new «superMM.adapterNameFor(superType, other.name)»(«asp.type.fullyQualifiedName».«op.simpleName»(new «mm.adapterNameFor(superMM, cls.name)»(adaptee)«paramsList»)) ;
														«ELSE»
														«IF returnType.simpleName != "void"»return «ENDIF»«asp.type.fullyQualifiedName».«op.simpleName»(new «mm.adapterNameFor(superMM, cls.name)»(adaptee)«paramsList») ;
														«ENDIF»
													'''
												]
											]
								]
							}
						]
					
					acceptor.accept(mm.toClass(mm.factoryNameFor(superType, inCls.name)))
						.initializeLater[
							superTypes += newTypeRef(AdapterFactory, newTypeRef(inCls.fullyQualifiedName.toString))
							
							members += mm.toMethod("newObject", newTypeRef(GenericAdapter, newTypeRef(inCls.fullyQualifiedName.toString)))[
								parameters += mm.toParameter("adaptee", newTypeRef(inCls.fullyQualifiedName.toString))
								body = '''
									return new «mm.adapterNameFor(superType, inCls.name)»(adaptee) ;
								'''
							]
						]
				]
				
				acceptor.accept(mm.toClass(mm.adapterNameFor(superType, mm.factoryName)))
					.initializeLater[
						superTypes += newTypeRef(superType.interfaceNameFor(superPkg.factoryName))
						
						// !!!
						members += mm.toField("adaptee", newTypeRef(pkg.name + "." + pkg.name.toFirstUpper + "Factory"))[
							initializer = '''«pkg.name».«pkg.name.toFirstUpper»Factory.eINSTANCE'''
						]
						
						superPkg.EClassifiers.filter(EClass).filter[!^abstract && !^interface].forEach[cls |
							members += mm.toMethod("create" + cls.name, newTypeRef(superType.interfaceNameFor(cls.name)), [
								body = '''
									return new «mm.adapterNameFor(superType, cls.name)»(adaptee.create«cls.name»()) ;
								'''
							])
						]
					]
				
				adapSwitch.append('''case "«name»": return (T) new «mm.adapterNameFor(superType, mm.name)»(res) ;''' + "\n")
			]
			
		acceptor.accept(mm.toClass(mm.fullyQualifiedName.normalize))
			.initializeLater[
				val paramT = TypesFactory::eINSTANCE.createJvmTypeParameter => [
					name = "T"
					constraints += TypesFactory.eINSTANCE.createJvmUpperBound => [
						typeReference = mm.newTypeRef(ModelType)
					]
				]
				
				members += mm.toMethod("load", paramT.newTypeRef) [
					^static = true
					
					typeParameters += paramT
					parameters += mm.toParameter("uri", newTypeRef(String))
					parameters += mm.toParameter("type", mm.newTypeRef(Class, paramT.newTypeRef))
					
					exceptions += mm.newTypeRef(ModelTypeException)
					
					body = '''
						org.eclipse.emf.ecore.resource.ResourceSet resSet = new org.eclipse.emf.ecore.resource.impl.ResourceSetImpl() ;
    					org.eclipse.emf.ecore.resource.Resource res = resSet.getResource(org.eclipse.emf.common.util.URI.createURI(uri), true) ;
    					
						switch (type.getName()) {
							«adapSwitch»
						}
						
						throw new fr.inria.diverse.k3.sle.lib.ModelTypeException("Cannot load " + uri + " using MT(" + type + ") : incompatible types") ;
					'''
				]
			]
		
		if (mm.superMetamodels.size > 0) {
			val superMM = mm.superMetamodels.head
			val superPkg = superMM.pkg
			
			superPkg.EClassifiers.filter(EClass).forEach[cls |
				val inCls = pkg.EClassifiers.filter(EClass).findFirst[name == cls.name]
				
				acceptor.accept(mm.toClass(mm.adapterNameFor(superMM, cls.name)))
					.initializeLater[
						superTypes += newTypeRef(cls.fullyQualifiedName.toString)
						superTypes += newTypeRef(EObjectAdapter, newTypeRef(inCls.fullyQualifiedName.toString))
						
						members += mm.toConstructor[
								parameters += mm.toParameter("adaptee", newTypeRef(inCls.fullyQualifiedName.toString))
								body = '''super(adaptee) ;'''
							]
							
							cls.EAllAttributes.forEach[attr |
								val baseType =
									if (attr.EAttributeType != null)
										newTypeRef(attr.EAttributeType.instanceClassName)
									else
										newTypeRef(inCls.fullyQualifiedName.toString)
								
								val returnType = if (attr.many) newTypeRef(List, baseType) else	baseType
								
								members += attr.toMethod(attr.getterName, returnType)[
									body = '''return adaptee.«attr.getterName»() ;'''
								]
								
								if (!attr.many)
									members += attr.toMethod(attr.setterName, newTypeRef(Void::TYPE))[
										parameters += attr.toParameter("o", baseType)
										body = '''adaptee.«attr.setterName»(o) ;'''
									]
							]
							
							cls.EAllReferences.forEach[ref |
								val inRef = inCls.EReferences.findFirst[it.name == ref.name]
								val adapName = mm.adapterNameFor(superMM, ref.EReferenceType.name)
								val baseType = newTypeRef(ref.EReferenceType.fullyQualifiedName.toString)
									
								if (ref.many)
									members += ref.toMethod(ref.getterName, newTypeRef(EList, baseType))[
										body = '''
											return new fr.inria.diverse.k3.sle.lib.EListAdapter<
												«ref.EReferenceType.fullyQualifiedName.toString»,
												«inRef.EReferenceType.fullyQualifiedName.toString»,
												«adapName»>(adaptee.«ref.getterName»(), new «adapName»Factory()
											) ;
										'''
									]
								else {
									members += ref.toMethod(ref.getterName, baseType)[
											body = '''return new «adapName»(adaptee.«ref.getterName»()) ;'''
										]
									members += ref.toMethod(ref.setterName, newTypeRef(Void::TYPE))[
											parameters += ref.toParameter("o", newTypeRef(ref.EReferenceType.fullyQualifiedName.toString))
											body = '''
												«adapName» wrap = («adapName») o ;
												adaptee.«ref.setterName»(wrap.getAdaptee()) ;
											'''
										]
								}
							]
					]
				
				acceptor.accept(mm.toClass(mm.adapterNameFor(superMM, cls.name) + "Factory"))
					.initializeLater[
						superTypes += newTypeRef(AdapterFactory, newTypeRef(inCls.fullyQualifiedName.toString))
						
						members += mm.toMethod("newObject", newTypeRef(GenericAdapter, newTypeRef(inCls.fullyQualifiedName.toString)))[
							parameters += mm.toParameter("adaptee", newTypeRef(inCls.fullyQualifiedName.toString))
							body = '''
								return new «mm.adapterNameFor(superMM, cls.name)»(adaptee) ;
							'''
						]
					]
			]
		}
		
		registerEffectivePkg(mm, pkg)
	}
	
	def dispatch void infer(ModelTypeDecl mt, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
		log("Infering MT " + mt.name)
		
		if (mt.extracted != null) {
			// !!!
			val mm = mt.extracted
			val uri = mm.allEcores.head.uri
			val pkg = ModelUtils.loadPkg(uri)
			val mtI = mt.toInterface(mt.fullyQualifiedName.normalize.toString, [])
			
			pkg.weaveAspects(mm)
			
			acceptor.accept(mtI)
				.initializeLater[
					superTypes += newTypeRef(ModelType)
					
					members += mt.toMethod("getContents", newTypeRef(List, newTypeRef(Object)))[
						abstract = true
					]
					
					members += mt.toMethod("getFactory", newTypeRef(mt.interfaceNameFor(pkg.factoryName)))[
						abstract = true
					]
				]
			
			pkg.EClassifiers.filter(EClass).forEach[cls |
				acceptor.accept(cls.toInterface(mt.interfaceNameFor(cls.name), []))
					.initializeLater[					
						cls.ESuperTypes.forEach[sup |
							superTypes += newTypeRef(mt.interfaceNameFor(sup.name))
						]
						
						cls.EAttributes.forEach[attr |
							val baseType =
								if (attr.EAttributeType != null)
									newTypeRef(attr.EAttributeType.instanceClassName)
								else
									newTypeRef(mt.interfaceNameFor(attr.EType.name))
							
							val returnType = if (attr.many)	newTypeRef(List, baseType) else	baseType
							
							members += attr.toGetterSignature(attr.name, returnType)
							
							if (!attr.many)
								members += attr.toSetterSignature(attr.name, returnType)
						]
						
						cls.EReferences.forEach[ref |
							if (ref.many) {
								members += ref.toGetterSignature(ref.name, newTypeRef(typeof(List), newTypeRef(mt.interfaceNameFor(ref.EReferenceType.name))))
							} else {
								members += ref.toGetterSignature(ref.name, ref.newTypeRef(ref.EReferenceType.name))
								members += ref.toSetterSignature(ref.name, ref.newTypeRef(ref.EReferenceType.name))
							}
						]
						
						mm.aspects
							// !!!
							.filter[type.declaredOperations.filter[op | !op.simpleName.startsWith("priv")].forall[parameters.head?.parameterType?.simpleName == cls.name]]
							.forEach[asp |
								log("mtAsp="+asp.type.qualifiedName)
								asp.type.declaredOperations
									.filter[op | !op.simpleName.startsWith("priv") && !op.simpleName.startsWith("super_")]
									.filter[op | !members.exists[opp | opp.simpleName == op.simpleName]]
									.forEach[op |
										log("mtOp="+op.simpleName)
										members += mt.toMethod(op.simpleName, newTypeRef(op.returnType.qualifiedName))[
											val other = pkg.EClassifiers.filter(EClass).findFirst[ccls | ccls.name == op.returnType.simpleName]
											
											if (other != null)
												returnType = newTypeRef(mt.interfaceNameFor(other.name))
											
											op.parameters.forEach[p, i |
												if (i > 0) {
													val otherr = pkg.EClassifiers.filter(EClass).findFirst[ccls | ccls.name == p.parameterType.simpleName]
													
													if (otherr != null)
														parameters += mt.toParameter(p.simpleName, newTypeRef(mt.interfaceNameFor(otherr.name)))
													else
														parameters += mt.toParameter(p.simpleName, p.parameterType)
												}
											]
											
											^abstract = true
										]
									]
							]
					]
			]
			
			pkg.extractFactoryInterface(mt.fullyQualifiedName, acceptor)
			registerMT(mt, pkg)
		}
	}
	
	def dispatch void infer(TransformationDecl transfo, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
		log("Infering T " + transfo.name)
		acceptor.accept(transfo.toClass(transfo.fullyQualifiedName))
			.initializeLater[
				// !!!
				members += transfo.toMethod("call", transfo.newTypeRef(Void::TYPE))[
					transfo.parameters.forEach[p |
						parameters += transfo.toParameter(p.name, p.parameterType)
					]
					body = transfo.body
					static = true
				]
				
				if (transfo.main) {
					members += transfo.toMethod("main", newTypeRef(Void::TYPE))[
						parameters += transfo.toParameter("args", transfo.newTypeRef(typeof(String)).addArrayTypeDimension)
						
						body = '''
							«FOR pkg : effectivePkgs.values»
							org.eclipse.emf.ecore.EPackage.Registry.INSTANCE.put(
								«pkg.fullyQualifiedName.toString».«pkg.fullyQualifiedName.toString.toFirstUpper»Package.eNS_URI,
								«pkg.fullyQualifiedName.toString».«pkg.fullyQualifiedName.toString.toFirstUpper»Package.eINSTANCE
							) ;
							«ENDFOR»
							org.eclipse.emf.ecore.resource.Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put(
								"*",
								new org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl()
							) ;
							
							«transfo.fullyQualifiedName».call() ;
						'''
						static = true
					]
				}
			]
	}
	
	def registerMT(ModelTypeDecl mt, EPackage pkg) {
		if (!registeredMTs.containsKey(mt.fullyQualifiedName.toString))
			registeredMTs.put(mt.fullyQualifiedName.toString, mt -> pkg)
	}
	
	def registerEffectivePkg(MetamodelDecl mm, EPackage pkg) {
		if (!effectivePkgs.containsKey(mm.fullyQualifiedName.toString))
			effectivePkgs.put(mm.fullyQualifiedName.toString, pkg)
	}
	
	def extractFactoryInterface(EPackage pkg, QualifiedName targetPkg, IJvmDeclaredTypeAcceptor acceptor) {
		acceptor.accept(pkg.toInterface(targetPkg.append(pkg.factoryName).normalize.toString, []))
			.initializeLater[
				superTypes += newTypeRef(IFactory)
				
				pkg.EClassifiers.filter(EClass).filter[!^abstract && !^interface].forEach[cls |
					members += cls.toMethod("create" + cls.name, newTypeRef(targetPkg.append(cls.name).normalize.toString), [
						abstract = true
					])
				]
			]
	}
	
	def toGetterSignature(EObject o, String name, JvmTypeReference type) {
		val g = o.toGetter(name, type)
		g.removeExistingBody
		
		if (#["java.lang.Boolean", "boolean"].contains(type.qualifiedName))
			g.simpleName = g.simpleName.replaceFirst("get", "is")
		
		return g
	}
	
	def toSetterSignature(EObject o, String name, JvmTypeReference type) {
		val s = o.toSetter(name, type)
		s.removeExistingBody
		
		return s
	}
	
	// FIXME
	def getRoot(EPackage pkg) {
		return pkg.EClassifiers.filter(EClass).head
	}
	
	def adapterNameFor(MetamodelDecl mm, ModelTypeDecl mt, String cls) {
		mm.fullyQualifiedName.append("adapters").append(mt.fullyQualifiedName.lastSegment).append(cls + "Adapter").normalize.toString
	}
	
	def adapterNameFor(MetamodelDecl mm, MetamodelDecl superMM, String cls) {
		mm.fullyQualifiedName.append("adapters").append(superMM.name).append(cls + "Adapter").normalize.toString
	}
	
	def factoryNameFor(MetamodelDecl mm, ModelTypeDecl mt, String cls) {
		mm.fullyQualifiedName.append("adapters").append(mt.fullyQualifiedName.lastSegment).append(cls + "AdapterFactory").normalize.toString
	}
	
	def interfaceNameFor(ModelTypeDecl mt, String cls) {
		mt.fullyQualifiedName.append(cls).normalize.toString
	}
	
	def log(String s) {
		val debug = new PrintWriter(new BufferedWriter(new FileWriter(DEBUG_FILE, true)))
		debug.write("[" + new java.util.Date() + "] " + s + "\n")
		debug.close
	}
}
