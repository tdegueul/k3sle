package fr.inria.diverse.k3.sle.tests

import fr.inria.diverse.k3.sle.K3SLEInjectorProvider
import fr.inria.diverse.k3.sle.k3sle.ModelRoot
import fr.inria.diverse.k3.sle.k3sle.MetamodelDecl

import com.google.inject.Inject

import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper

import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(K3SLEInjectorProvider)
class SimpleParsingTest {

	@Inject extension ParseHelper<ModelRoot>

	@Test
	def void testSimpleMM() {
		val root = '''
			package foo

			metamodel M1 {

			}
		'''.parse

		assertEquals(root.elements.size, 1)
		assertTrue(root.elements.head instanceof MetamodelDecl)

		val mm = root.elements.head as MetamodelDecl
		assertEquals(mm.name, "M1")
		assertEquals(mm.aspects.size, 0)
		assertNull(mm.ecore)
	}

	@Test
	def void testInheritsMM() {
		val root = '''
			package foo

			metamodel Sup {}
			metamodel Sub inherits Sup {}
		'''.parse

		assertEquals(root.elements.size, 2)
		assertTrue(root.elements.forall[it instanceof MetamodelDecl])

		val sup = root.elements.get(0) as MetamodelDecl
		val sub = root.elements.get(1) as MetamodelDecl

		assertEquals(sup.name, "Sup")
		assertEquals(sup.aspects.size, 0)
		assertNull(sup.ecore)

		assertEquals(sub.name, "Sub")
		assertEquals(sub.aspects.size, 0)
		assertEquals(sub.superMetamodel, sup)
		assertNull(sub.ecore)
	}
}
