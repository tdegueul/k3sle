/**
 */
package fr.inria.diverse.k3.sle.metamodel.k3sle;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Inheritance</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * <ul>
 *   <li>{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Inheritance#getSubMetamodel <em>Sub Metamodel</em>}</li>
 *   <li>{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Inheritance#getSuperMetamodel <em>Super Metamodel</em>}</li>
 * </ul>
 * </p>
 *
 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.K3slePackage#getInheritance()
 * @model
 * @generated
 */
public interface Inheritance extends EObject {
	/**
	 * Returns the value of the '<em><b>Sub Metamodel</b></em>' container reference.
	 * It is bidirectional and its opposite is '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Metamodel#getInheritanceRelation <em>Inheritance Relation</em>}'.
	 * <!-- begin-user-doc -->
	 * <p>
	 * If the meaning of the '<em>Sub Metamodel</em>' container reference isn't clear,
	 * there really should be more of a description here...
	 * </p>
	 * <!-- end-user-doc -->
	 * @return the value of the '<em>Sub Metamodel</em>' container reference.
	 * @see #setSubMetamodel(Metamodel)
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.K3slePackage#getInheritance_SubMetamodel()
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.Metamodel#getInheritanceRelation
	 * @model opposite="inheritanceRelation" required="true" transient="false"
	 * @generated
	 */
	Metamodel getSubMetamodel();

	/**
	 * Sets the value of the '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Inheritance#getSubMetamodel <em>Sub Metamodel</em>}' container reference.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @param value the new value of the '<em>Sub Metamodel</em>' container reference.
	 * @see #getSubMetamodel()
	 * @generated
	 */
	void setSubMetamodel(Metamodel value);

	/**
	 * Returns the value of the '<em><b>Super Metamodel</b></em>' reference.
	 * <!-- begin-user-doc -->
	 * <p>
	 * If the meaning of the '<em>Super Metamodel</em>' reference isn't clear,
	 * there really should be more of a description here...
	 * </p>
	 * <!-- end-user-doc -->
	 * @return the value of the '<em>Super Metamodel</em>' reference.
	 * @see #setSuperMetamodel(Metamodel)
	 * @see fr.inria.diverse.k3.sle.metamodel.k3sle.K3slePackage#getInheritance_SuperMetamodel()
	 * @model required="true"
	 * @generated
	 */
	Metamodel getSuperMetamodel();

	/**
	 * Sets the value of the '{@link fr.inria.diverse.k3.sle.metamodel.k3sle.Inheritance#getSuperMetamodel <em>Super Metamodel</em>}' reference.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @param value the new value of the '<em>Super Metamodel</em>' reference.
	 * @see #getSuperMetamodel()
	 * @generated
	 */
	void setSuperMetamodel(Metamodel value);

} // Inheritance
