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
					(opA.EType as EClass).EAllSuperTypes.contains(opB.EType)
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
}
