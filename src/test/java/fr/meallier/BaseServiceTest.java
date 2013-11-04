package fr.meallier;

import java.util.Properties;

import javax.ejb.embeddable.EJBContainer;

import org.junit.After;
import org.junit.Before;

public abstract class BaseServiceTest {

	private EJBContainer container;

	@Before
	public void createContainer() throws Exception {
		Properties p = new Properties();

		container = EJBContainer.createEJBContainer(p);
		container.getContext().bind("inject", this);
	}

	@After
	public void closeContainer() throws Exception {
		if (container != null)
			container.close();
	}

}