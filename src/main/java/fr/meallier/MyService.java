package fr.meallier;

import javax.ejb.Stateless;
import javax.ejb.TransactionAttribute;
import javax.ejb.TransactionAttributeType;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Stateless
@TransactionAttribute(TransactionAttributeType.REQUIRED)
public class MyService {

	Logger logger = LoggerFactory.getLogger(MyService.class);

	public String getValue() {
		logger.info("Call getValue");
		return "Hello";
	}
}
