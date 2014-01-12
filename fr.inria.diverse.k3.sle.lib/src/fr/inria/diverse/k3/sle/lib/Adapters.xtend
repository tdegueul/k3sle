package fr.inria.diverse.k3.sle.lib

import com.google.common.base.Function
import com.google.common.collect.Iterators

import java.util.Collection
import java.util.List

abstract class GenericAdapter<E> {
	protected E adaptee
	
	new(E a) { adaptee = a }
	def E getAdaptee() { adaptee }
}

interface AdapterFactory<A> {
	def GenericAdapter<A> newObject(A adaptee)
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

class IteratorTranslator<E, F> implements Function<E, F> {
	AdapterFactory<E> factory
	
	new(AdapterFactory<E> f) { factory = f }
	
	override apply(E arg) {
		factory.newObject(arg) as F
	}
}
	