package fr.inria.diverse.k3.sle.jvmmodel

import java.util.List
import java.util.ArrayList

import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EReference

import org.eclipse.xtext.naming.QualifiedName

import fr.inria.diverse.k3.sle.k3sle.MetamodelDecl
import fr.inria.diverse.k3.sle.k3sle.EcoreDecl
import fr.inria.diverse.k3.sle.k3sle.AspectDecl
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import java.util.ArrayList
import org.eclipse.emf.codegen.ecore.genmodel.GenModelFactory
import org.eclipse.emf.codegen.ecore.genmodel.GenJDKLevel
import java.nio.file.Path
import java.util.Collections
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.eclipse.emf.ecore.xmi.XMLResource
import fr.inria.diverse.k3.sle.lib.ModelUtils
import org.eclipse.emf.codegen.ecore.generator.GeneratorAdapterFactory
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenModelGeneratorAdapterFactory
import org.eclipse.emf.codegen.ecore.generator.Generator
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter
import org.eclipse.emf.common.util.BasicMonitor
import org.eclipse.emf.codegen.ecore.genmodel.util.GenModelUtil
import org.eclipse.emf.codegen.ecore.genmodel.GenModel
import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.emf.ecore.EcorePackage

class K3SLEJvmModelInferrerHelper
{
	static def normalize(QualifiedName name) {
		name.skipLast(1).toLowerCase.append(name.lastSegment.toFirstUpper)
	}
	
	static def boolean subtypeOf(EPackage pkgA, EPackage pkgB) {
		pkgB.EClassifiers.filter(EClass).forall[clsB |
			pkgA.EClassifiers.filter(EClass).exists[clsA | clsA.correspondsTo(clsB)]
		]
	}
	
	static def boolean correspondsTo(EClass clsA, EClass clsB) {
		    clsA.name == clsB.name
		&&  clsB.EOperations.forall[opB |
				clsA.EOperations.exists[opA | opA.correspondsTo(opB)]
			]
		&&  clsB.EAttributes.forall[attrB |
				clsA.EAttributes.exists[attrA | attrA.correspondsTo(attrB)]
			]
		&&  clsB.EReferences.forall[refB |
				clsA.EReferences.exists[refA | refA.correspondsTo(refB)]
			]
	}
	
	static def boolean correspondsTo(EOperation opA, EOperation opB) {
		    opA.name == opB.name
		&&  if (opA.EType instanceof EDataType || opB.EType instanceof EDataType)
				opA.EType == opB.EType
			else
				(
					   opA.EContainingClass.EPackage.EClassifiers.contains(opA.EType)
					&& opB.EContainingClass.EPackage.EClassifiers.contains(opB.EType)
					&& (opA.EType as EClass).correspondsTo(opB.EType as EClass)
				) || (
					//(opA.EType as EClass).EAllSuperTypes.contains(opB.EType)
					true
				)
		&&  parametersListMatch(opA.EParameters, opB.EParameters)
		&&  opA.EExceptions.forall[excA |
				opB.EExceptions.exists[excB |
					if (excA instanceof EDataType || excB instanceof EDataType)
						excA == excB
					else
						(
							   opA.EContainingClass.EPackage.EClassifiers.contains(excA)
							&& opB.EContainingClass.EPackage.EClassifiers.contains(excB)
							&& (excA as EClass).correspondsTo(excB as EClass)
						) || (
							(excA as EClass).EAllSuperTypes.contains(excB)
						)
				]
			]
	}
	
	static def boolean parametersListMatch(List<EParameter> paramsA, List<EParameter> paramsB) {
		var rank = 0
		
		for (paramB : paramsB) {
			if (rank >= paramsA.size)
				return false
			
			val paramA = paramsA.get(rank)
			
			if (paramA.EType instanceof EDataType || paramB.EType instanceof EDataType)
				if (paramA.EType != paramB.EType)
					return false
			else if (paramA.EOperation.EContainingClass.EPackage.EClassifiers.contains(paramA.EType)
					&& paramB.EOperation.EContainingClass.EPackage.EClassifiers.contains(paramB.EType))
				if (!(paramA.EType as EClass).correspondsTo(paramB.EType as EClass))
					return false
			else
				if (!(paramA.EType as EClass).EAllSuperTypes.contains(paramB.EType))
					return false
			
			if (
				   paramA.lowerBound != paramB.lowerBound
				|| paramA.upperBound != paramB.upperBound
				|| paramA.unique != paramB.unique
				|| paramA.ordered && !paramB.ordered
			)
				return false
			
			rank = rank + 1	
		}
		
		true
	}
	
	static def boolean correspondsTo(EAttribute attrA, EAttribute attrB) {
		    attrA.name == attrB.name
		&&  (attrA.changeable || !attrB.changeable)
		&&  (attrA.unique == attrB.unique)
		&&  (!attrA.ordered || attrB.ordered)
		&&  if (attrA.EType instanceof EDataType || attrB.EType instanceof EDataType)
				attrA.EType == attrB.EType
			else
				(
					   attrA.EContainingClass.EPackage.EClassifiers.contains(attrA.EType)
					&& attrB.EContainingClass.EPackage.EClassifiers.contains(attrB.EType)
					&& (attrA.EType as EClass).correspondsTo(attrB.EType as EClass)
				) || (
					   (attrA.EType as EClass).EAllSuperTypes.contains(attrB.EType)
					&& !attrA.changeable
				)
		&&  (attrA.lowerBound == attrB.lowerBound)
		&&  (attrA.upperBound == attrB.upperBound)
	}
	
	static def boolean correspondsTo(EReference refA, EReference refB) {
		    refA.name == refB.name
		&&  (refA.changeable || !refB.changeable)
		&&  (refA.containment == refB.containment)
		&&  (refA.unique == refB.unique)
		&&  (!refA.ordered || refB.ordered)
		&&  (refA.lowerBound == refB.lowerBound)
		&&  (refA.upperBound == refB.upperBound)
		&&  (!(refA.EOpposite != null) || (refB.EOpposite != null && refA.EOpposite.name == refB.EOpposite.name))
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
		
		ret.addAll(mm.ecores)
		mm.superMetamodels.forEach[ret.addAll(it.ecores)]
		
		return ret
	}
	
	static def getAllAspects(MetamodelDecl mm) {
		val ret = new ArrayList<AspectDecl>
		
		ret.addAll(mm.aspects)
		mm.superMetamodels.forEach[ret.addAll(it.aspects)]
		
		return ret
	}
	
	static def getUri(MetamodelDecl mm) {
		if (mm.ecores.empty && !mm.superMetamodels.empty)
			'''platform:/resource/«mm.name»Generated/model/«mm.name».ecore'''
		else
			mm.ecores.head.uri
	}
	
	static def getPkg(MetamodelDecl mm) {
		if (mm.ecores.empty && !mm.superMetamodels.empty)
		{
			val superMM = mm.superMetamodels.head
			val superPkg = ModelUtils.loadPkg(superMM.ecores.head.uri)
			val pkg = superPkg.copy(mm.name)
			val uri = mm.uri
			val genModelUri = '''platform:/resource/«mm.name»Generated/model/«mm.name».genmodel'''
			
			pkg.createEcore(uri.toString)
			pkg.createGenModel(mm, uri.toString, genModelUri)
			
			return pkg
		} else {
			val uri = mm.ecores.head.uri
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
		val d = generator.generate(
			genModel,
			GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE,
			new BasicMonitor.Printing(System.out)
		)
	}
	
	static def weaveAspects(EPackage pkg, MetamodelDecl mm) {
		mm.aspects.forEach[asp |
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
}
