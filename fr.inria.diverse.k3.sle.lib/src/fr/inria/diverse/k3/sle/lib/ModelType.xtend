package fr.inria.diverse.k3.sle.lib

import java.util.List

interface ModelType
{
	def List<Object> getContents()
	def IFactory getFactory()
}

interface IFactory
{}
