package fr.inria.diverse.k3.sle.jvmmodel

import org.eclipse.emf.common.util.BasicMonitor

import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil

import org.eclipse.emf.codegen.ecore.genmodel.GenModelFactory
import org.eclipse.emf.codegen.ecore.genmodel.GenJDKLevel
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter
import org.eclipse.emf.codegen.ecore.genmodel.util.GenModelUtil
import org.eclipse.emf.codegen.ecore.genmodel.GenModel
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage

import fr.inria.diverse.k3.sle.k3sle.MetamodelDecl
import fr.inria.diverse.k3.sle.k3sle.EcoreDecl
import fr.inria.diverse.k3.sle.k3sle.AspectDecl

import fr.inria.diverse.k3.sle.lib.ModelUtils
import fr.inria.diverse.k3.sle.lib.MatchingHelper

import org.eclipse.xtext.naming.QualifiedName

import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.xtext.common.types.JvmCustomAnnotationValue

import java.util.Collections
import java.util.ArrayList

class K3SLEJvmModelInferrerHelper
{
	static def normalize(QualifiedName name) {
		name.skipLast(1).toLowerCase.append(name.lastSegment.toFirstUpper)
	}
	
	static def boolean subtypeOf(EPackage pkgA, EPackage pkgB) {
		new MatchingHelper(pkgA, pkgB).match
	}
	
	static def dispatch getFactoryName(EPackage pkg) {
		"I" + pkg.name.toFirstUpper + "Factory"
	}
	
	static def dispatch getFactoryName(MetamodelDecl mm) {
		mm.name + "Factory"
	}
	
	static def getterName(EAttribute attr) {
		if (#["java.lang.Boolean", "boolean"].contains(attr.EAttributeType.instanceClassName))
			"is" + attr.name.toFirstUpper
		else
			"get" + attr.name.toFirstUpper
	}
	
	static def setterName(EAttribute attr) {
		"set" + attr.name.toFirstUpper
	}
	
	static def getterName(EReference attr) {
		"get" + attr.name.toFirstUpper
	}
	
	static def setterName(EReference attr) {
		"set" + attr.name.toFirstUpper
	}
	
	static def getAllEcores(MetamodelDecl mm) {
		val ret = new ArrayList<EcoreDecl>
		
		if (mm.ecore != null)
			ret.add(mm.ecore)
		
		if (mm.superMetamodel != null)
			ret.add(mm.superMetamodel.ecore)
		
		return ret
	}
	
	static def getAllAspects(MetamodelDecl mm) {
		val ret = new ArrayList<AspectDecl>
		
		ret.addAll(mm.aspects)
		
		if (mm.superMetamodel != null)
			ret.addAll(mm.superMetamodel.aspects)
		
		return ret
	}
	
	static def getUri(MetamodelDecl mm) {
		if (mm.ecore == null && mm.superMetamodel != null)
			'''platform:/resource/«mm.name»Generated/model/«mm.name».ecore'''
		else
			mm.ecore.uri
	}
	
	static def getPkg(MetamodelDecl mm) {
		if (mm.ecore == null && mm.superMetamodel != null)
		{
			val superMM = mm.superMetamodel
			val superPkg = ModelUtils.loadPkg(superMM.ecore.uri)
			val pkg = superPkg.copy(mm.name)
			val uri = mm.uri
			val genModelUri = '''platform:/resource/«mm.name»Generated/model/«mm.name».genmodel'''
			
			pkg.createEcore(uri.toString)
			pkg.createGenModel(mm, uri.toString, genModelUri)
			
			return pkg
		} else {
			val uri = mm.ecore.uri
			val pkg = ModelUtils.loadPkg(uri)
			
			return pkg
		}
	}
	
	static def copy(EPackage pkg, String pkgName) {
		val newPkg = EcoreFactory.eINSTANCE.createEPackage => [
			name = pkgName.toLowerCase
			nsPrefix = pkgName.toLowerCase
			nsURI = '''http://«pkgName.toLowerCase»/'''
		]
		
		newPkg.EClassifiers.addAll(EcoreUtil.copyAll(pkg.EClassifiers))
		
		return newPkg
	}
	
	static def createEcore(EPackage pkg, String uri) {
		val resSet = new ResourceSetImpl
    	val res = resSet.createResource(org.eclipse.emf.common.util.URI.createURI(uri))
    	res.contents.add(pkg)
    	res.save(null)
	}
	
	static def createGenModel(EPackage pkg, MetamodelDecl mm, String ecoreLocation, String genModelLocation) {
		val genModelFact = GenModelFactory.eINSTANCE
		val genModel = genModelFact.createGenModel
		
		genModel.complianceLevel = GenJDKLevel.JDK70_LITERAL
		genModel.modelDirectory = '''/«mm.name»Generated/src'''
		genModel.foreignModel.add(ecoreLocation)
		genModel.modelName = mm.name
		genModel.initialize(Collections.singleton(pkg))
		
		val genPackage = genModel.genPackages.head as GenPackage
		genPackage.prefix = mm.name.toLowerCase.toFirstUpper
		
		val resSet = new ResourceSetImpl
		val res = resSet.createResource(org.eclipse.emf.common.util.URI.createURI(genModelLocation))
		res.contents.add(genModel)
		res.save(null)
		
		genModel.generateCode
	}
	
	static def generateCode(GenModel genModel) {
		genModel.reconcile
		genModel.canGenerate = true
		genModel.validateModel = true
		
		val generator = GenModelUtil.createGenerator(genModel)
		generator.generate(
			genModel,
			GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE,
			new BasicMonitor.Printing(System.out)
		)
	}
	
	// TODO: fixme
	static def weaveAspects(EPackage pkg, MetamodelDecl mm) {
		mm.allAspects.forEach[asp |
			val aspectized = pkg.EClassifiers.filter(EClass).findFirst[cls |
				asp.type.eAllContents.filter(JvmOperation)
				.filter[op | !op.simpleName.startsWith("priv") && !op.simpleName.startsWith("super_")]
				.forall[op | op.parameters.head?.parameterType?.simpleName == cls.name]
			]
			
			if (aspectized != null) {
				asp.type.eAllContents.filter(JvmOperation)
				.filter[op | !op.simpleName.startsWith("priv") && !op.simpleName.startsWith("super_")]
				.forEach[op |
					aspectized.EOperations.add(
						EcoreFactory.eINSTANCE.createEOperation => [
							val retType = pkg.getClassifierFor(op.returnType.simpleName)
							
							name = op.simpleName
							op.parameters.forEach[p, i |
								if (i > 0) {
									val pType = pkg.getClassifierFor(p.parameterType.simpleName)
									
									EParameters += EcoreFactory.eINSTANCE.createEParameter => [pp |
										pp.name = p.simpleName
										pp.EType = if (pType != null) pType else EcorePackage.eINSTANCE.getClassifierFor("E" + p.parameterType.simpleName.toFirstUpper)
									]
								}
							]
							EType = if (retType != null) retType else EcorePackage.eINSTANCE.getClassifierFor("E" + op.returnType.simpleName.toFirstUpper)
						]
					)
				]
			}
		]
	}
	
	static def getClassifierFor(EPackage pkg, String name) {
		return pkg.EClassifiers.findFirst[it.name == name]
	}
	
	static def isComplete(MetamodelDecl mm) {
		   (mm.ecore != null
		&& mm.ecore.uri != null)
		|| (mm.ecore == null
		&&  mm.superMetamodel.ecore != null
		&&  mm.superMetamodel.ecore.uri != null)
		//&& isValidEcorePath(...)
	}
	
	static def aspectizedBy(EClass cls, AspectDecl asp) {
		if (asp.type != null && asp.type.annotations.size > 0) {
			val className =
				asp.type.annotations
					.findFirst[annotation.qualifiedName == "fr.inria.triskell.k3.Aspect"]
					.values.filter(JvmCustomAnnotationValue)
					.head.values.head.toString
			
			return cls.name == className
		}
		
		true
	}
}
