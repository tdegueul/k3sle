/**
 */
package fr.inria.diverse.k3.sle.metamodel.k3sle.util;

import fr.inria.diverse.k3.sle.metamodel.k3sle.*;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.notify.Notifier;

import org.eclipse.emf.common.notify.impl.AdapterFactoryImpl;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * The <b>Adapter Factory</b> for the model.
 * It provides an adapter <code>createXXX</code> method for each class of the model.
 * <!-- end-user-doc -->
 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.K3slePackage
 * @generated
 */
public class K3sleAdapterFactory extends AdapterFactoryImpl {
	/**
	 * The cached model package.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	protected static K3slePackage modelPackage;

	/**
	 * Creates an instance of the adapter factory.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public K3sleAdapterFactory() {
		if (modelPackage == null) {
			modelPackage = K3slePackage.eINSTANCE;
		}
	}

	/**
	 * Returns whether this factory is applicable for the type of the object.
	 * <!-- begin-user-doc -->
	 * This implementation returns <code>true</code> if the object is either the model's package or is an instance object of the model.
	 * <!-- end-user-doc -->
	 * @return whether this factory is applicable for the type of the object.
	 * @generated
	 */
	@Override
	public boolean isFactoryForType(Object object) {
		if (object == modelPackage) {
			return true;
		}
		if (object instanceof EObject) {
			return ((EObject)object).eClass().getEPackage() == modelPackage;
		}
		return false;
	}

	/**
	 * The switch that delegates to the <code>createXXX</code> methods.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	protected K3sleSwitch<Adapter> modelSwitch =
		new K3sleSwitch<Adapter>() {
			@Override
			public Adapter caseMegamodelRoot(MegamodelRoot object) {
				return createMegamodelRootAdapter();
			}
			@Override
			public Adapter casePackageDecl(PackageDecl object) {
				return createPackageDeclAdapter();
			}
			@Override
			public Adapter caseElement(Element object) {
				return createElementAdapter();
			}
			@Override
			public Adapter caseMetamodel(Metamodel object) {
				return createMetamodelAdapter();
			}
			@Override
			public Adapter caseModelType(ModelType object) {
				return createModelTypeAdapter();
			}
			@Override
			public Adapter caseTransformation(Transformation object) {
				return createTransformationAdapter();
			}
			@Override
			public Adapter caseEcoreImport(EcoreImport object) {
				return createEcoreImportAdapter();
			}
			@Override
			public Adapter caseAspectImport(AspectImport object) {
				return createAspectImportAdapter();
			}
			@Override
			public Adapter caseInheritance(Inheritance object) {
				return createInheritanceAdapter();
			}
			@Override
			public Adapter caseSubtyping(Subtyping object) {
				return createSubtypingAdapter();
			}
			@Override
			public Adapter defaultCase(EObject object) {
				return createEObjectAdapter();
			}
		};

	/**
	 * Creates an adapter for the <code>target</code>.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @param target the object to adapt.
	 * @return the adapter for the <code>target</code>.
	 * @generated
	 */
	@Override
	public Adapter createAdapter(Notifier target) {
		return modelSwitch.doSwitch((EObject)target);
	}


	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.MegamodelRoot <em>Megamodel Root</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.MegamodelRoot
	 * @generated
	 */
	public Adapter createMegamodelRootAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.PackageDecl <em>Package Decl</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.PackageDecl
	 * @generated
	 */
	public Adapter createPackageDeclAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Element <em>Element</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.Element
	 * @generated
	 */
	public Adapter createElementAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Metamodel <em>Metamodel</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.Metamodel
	 * @generated
	 */
	public Adapter createMetamodelAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.ModelType <em>Model Type</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.ModelType
	 * @generated
	 */
	public Adapter createModelTypeAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Transformation <em>Transformation</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.Transformation
	 * @generated
	 */
	public Adapter createTransformationAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.EcoreImport <em>Ecore Import</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.EcoreImport
	 * @generated
	 */
	public Adapter createEcoreImportAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.AspectImport <em>Aspect Import</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.AspectImport
	 * @generated
	 */
	public Adapter createAspectImportAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Inheritance <em>Inheritance</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.Inheritance
	 * @generated
	 */
	public Adapter createInheritanceAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for an object of class '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Subtyping <em>Subtyping</em>}'.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null so that we can easily ignore cases;
	 * it's useful to ignore a case when inheritance will catch all the cases anyway.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.Subtyping
	 * @generated
	 */
	public Adapter createSubtypingAdapter() {
		return null;
	}

	/**
	 * Creates a new adapter for the default case.
	 * <!-- begin-user-doc -->
	 * This default implementation returns null.
	 * <!-- end-user-doc -->
	 * @return the new adapter.
	 * @generated
	 */
	public Adapter createEObjectAdapter() {
		return null;
	}

} //K3sleAdapterFactory
