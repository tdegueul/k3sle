package fr.inria.diverse.k3.sle.formatting

import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig

//import com.google.inject.Inject
//import fr.inria.diverse.k3.sle.services.K3SLEGrammarAccess

class K3SLEFormatter extends AbstractDeclarativeFormatter
{
	//@Inject extension K3SLEGrammarAccess

	override protected void configureFormatting(FormattingConfig c) {
	// It's usually a good idea to activate the following three statements.
	// They will add and preserve newlines around comments
	//		c.setLinewrap(0, 1, 2).before(SL_COMMENTRule)
	//		c.setLinewrap(0, 1, 2).before(ML_COMMENTRule)
	//		c.setLinewrap(0, 1, 1).after(ML_COMMENTRule)
	}
}
