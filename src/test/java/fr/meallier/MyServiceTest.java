package fr.meallier;

import javax.annotation.ManagedBean;
import javax.inject.Inject;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
@ManagedBean
public class MyServiceTest extends BaseServiceTest {

	@Inject
	MyService myService;

	@Test
	public void serviceTest() throws Exception {
		org.junit.Assert.assertTrue("Hello".endsWith(myService.getValue()));

	}
}