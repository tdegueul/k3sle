package fr.inria.diverse.k3.sle.lib

import com.google.common.base.Function
import com.google.common.collect.Iterators

import java.util.Collection
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.common.notify.Notification
import java.lang.reflect.InvocationTargetException

abstract class GenericAdapter<E> {
	protected E adaptee

	new(E a) { adaptee = a }
	def E getAdaptee() { adaptee }
}

interface AdapterFactory<A> {
	def GenericAdapter<A> newObject(A adaptee)
}

abstract class EObjectAdapter<E extends EObject> extends GenericAdapter<E> {
	new(E a) { super(a) }

	def eAllContents() {
		adaptee.eAllContents
	}

	def eClass() {
		adaptee.eClass
	}

	def eContainer() {
		adaptee.eContainer
	}

	def eContainingFeature() {
		adaptee.eContainingFeature
	}

	def eContainmentFeature() {
		adaptee.eContainmentFeature
	}

	def eContents() {
		adaptee.eContents
	}

	def eCrossReferences() {
		adaptee.eCrossReferences
	}

	def eGet(EStructuralFeature feature) {
		adaptee.eGet(feature)
	}

	def eGet(EStructuralFeature feature, boolean resolve) {
		adaptee.eGet(feature, resolve)
	}

	def eInvoke(EOperation operation, EList<?> arguments) throws InvocationTargetException {
		adaptee.eInvoke(operation, arguments)
	}

	def eIsProxy() {
		adaptee.eIsProxy
	}

	def eIsSet(EStructuralFeature feature) {
		adaptee.eIsSet(feature)
	}

	def eResource() {
		adaptee.eResource
	}

	def eSet(EStructuralFeature feature, Object newValue) {
		adaptee.eSet(feature, newValue)
	}

	def eUnset(EStructuralFeature feature) {
		adaptee.eUnset(feature)
	}

	def eAdapters() {
		adaptee.eAdapters
	}

	def eDeliver() {
		adaptee.eDeliver
	}

	def eNotify(Notification notification) {
		adaptee.eNotify(notification)
	}

	def eSetDeliver(boolean deliver) {
		adaptee.eSetDeliver(deliver)
	}
}

class ListAdapter<E, F, A extends GenericAdapter<F>> implements List<E>
{
	List<F> adaptee
	AdapterFactory<F> factory

	new(List<F> a, AdapterFactory<F> f) {
		adaptee = a
		factory = f
	}

	override add(E e) {
		adaptee.add(decapsulate(e))
	}

	override add(int index, E element) {
		adaptee.add(index, decapsulate(element))
	}

	override addAll(Collection<? extends E> c) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override addAll(int index, Collection<? extends E> c) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override clear() {
		adaptee.clear
	}

	override contains(Object o) {
		adaptee.contains(o)
	}

	override containsAll(Collection<?> c) {
		adaptee.containsAll(c)
	}

	override get(int index) {
		factory.newObject(adaptee.get(index)) as E
	}

	override indexOf(Object o) {
		adaptee.indexOf(o)
	}

	override isEmpty() {
		adaptee.isEmpty
	}

	override iterator() {
		return Iterators.transform(adaptee.iterator, new IteratorTranslator<F, E>(factory))
	}

	override lastIndexOf(Object o) {
		adaptee.lastIndexOf(decapsulate(o))
	}

	override listIterator() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override listIterator(int index) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override remove(Object o) {
		adaptee.remove(decapsulate(o))
	}

	override remove(int index) {
		factory.newObject(adaptee.remove(index)) as E
	}

	override removeAll(Collection<?> c) {
		adaptee.removeAll(c)
	}

	override retainAll(Collection<?> c) {
		adaptee.retainAll(c)
	}

	override set(int index, E element) {
		factory.newObject(adaptee.set(index, decapsulate(element))) as E
	}

	override size() {
		adaptee.size
	}

	override subList(int fromIndex, int toIndex) {
		new ListAdapter<E, F, A>(adaptee.subList(fromIndex, toIndex), factory)
	}

	override toArray() {
		adaptee.toArray
	}

	override <T> toArray(T[] a) {
		adaptee.toArray(a)
	}

	def decapsulate(Object e) {
		(e as GenericAdapter<F>).adaptee
	}
}

class EListAdapter<E, F, A extends GenericAdapter<F>> extends ListAdapter<E, F, A> implements EList<E>
{
	EList<F> adaptee
	AdapterFactory<F> factory

	new(EList<F> a, AdapterFactory<F> f) {
		super(a, f)
		adaptee = a
		factory = f
	}

	override add(E e) {
		adaptee.add(decapsulate(e))
	}

	override add(int index, E element) {
		adaptee.add(index, decapsulate(element))
	}

	override addAll(Collection<? extends E> c) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override addAll(int index, Collection<? extends E> c) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override clear() {
		adaptee.clear
	}

	override contains(Object o) {
		adaptee.contains(o)
	}

	override containsAll(Collection<?> c) {
		adaptee.containsAll(c)
	}

	override get(int index) {
		factory.newObject(adaptee.get(index)) as E
	}

	override indexOf(Object o) {
		adaptee.indexOf(o)
	}

	override isEmpty() {
		adaptee.isEmpty
	}

	override iterator() {
		return Iterators.transform(adaptee.iterator, new IteratorTranslator<F, E>(factory))
	}

	override lastIndexOf(Object o) {
		adaptee.lastIndexOf(decapsulate(o))
	}

	override listIterator() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override listIterator(int index) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override remove(Object o) {
		adaptee.remove(decapsulate(o))
	}

	override remove(int index) {
		factory.newObject(adaptee.remove(index)) as E
	}

	override removeAll(Collection<?> c) {
		adaptee.removeAll(c)
	}

	override retainAll(Collection<?> c) {
		adaptee.retainAll(c)
	}

	override set(int index, E element) {
		factory.newObject(adaptee.set(index, decapsulate(element))) as E
	}

	override size() {
		adaptee.size
	}

	override subList(int fromIndex, int toIndex) {
		new ListAdapter<E, F, A>(adaptee.subList(fromIndex, toIndex), factory)
	}

	override toArray() {
		adaptee.toArray
	}

	override <T> toArray(T[] a) {
		adaptee.toArray(a)
	}

	override move(int newPosition, E object) {
		adaptee.move(newPosition, (object as GenericAdapter<F>).adaptee)
	}

	override move(int newPosition, int oldPosition) {
		factory.newObject(adaptee.move(newPosition, oldPosition)) as E
	}
}

class IteratorTranslator<E, F> implements Function<E, F> {
	AdapterFactory<E> factory

	new(AdapterFactory<E> f) { factory = f }

	override apply(E arg) {
		factory.newObject(arg) as F
	}
}
