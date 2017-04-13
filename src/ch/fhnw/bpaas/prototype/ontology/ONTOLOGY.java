package ch.fhnw.bpaas.prototype.ontology;

public enum ONTOLOGY {
	
	APQC		("apqc",	"TTL",	"main/resources/apqc.ttl"),
	BPAAS		("bpaas",	"TTL",	"main/resources/bpaas.ttl"),
	BPAASRULES	("bpaas",	"TTL",	"main/resources/bpaasrules.ttl"),
	FBPDO		("fbpdo",	"TTL",	"main/resources/fbpdo.ttl"),
	TOP			("top",		"TTL",	"main/resources/ArchiMEO/TOP/TOP.ttl"),
	EO			("eo",		"TTL", 	"main/resources/ArchiMEO/EO/EO.ttl"),
	ARCHIMEO	("archimeo","TTL", 	"main/resources/ArchiMEO/ArchiMEO.ttl"),
	NCO			("nco",		"TTL", 	"main/resources/ArchiMEO/NCO/NCO.ttl"),
	BMM			("bmm",		"TTL", 	"main/resources/ArchiMEO/BMM/BMM.ttl");
	
//	BPAAS	("bpaas",		"TTL",	"https://raw.githubusercontent.com/BPaaSModelling/BPaaS-Ontology/master/bpaas.ttl"),
//	BPAASRULES	("bpaas",	"TTL",	"https://raw.githubusercontent.com/BPaaSModelling/BPaaS-Ontology/master/bpaasrules.ttl"),
//	APQC	("apqc",		"TTL",	"https://raw.githubusercontent.com/BPaaSModelling/APQC-Ontology/master/apqc.ttl"),
//	FBPDO	("fbpdo",		"TTL",	"https://raw.githubusercontent.com/BPaaSModelling/Functional-Business-Process-Description-Ontology/master/fbpdo.ttl"),
//	TOP		("top",			"TTL",	"https://raw.githubusercontent.com/ikm-group/ArchiMEO/master/ARCHIMEO/TOP/TOP.ttl"),
//	EO		("eo",			"TTL", 	"https://raw.githubusercontent.com/ikm-group/ArchiMEO/master/ARCHIMEO/EO/EO.ttl"),
//	ARCHIMEO("archimeo",	"TTL", 	"https://raw.githubusercontent.com/ikm-group/ArchiMEO/master/ARCHIMEO/ArchiMEO.ttl"),
//	NCO		("nco",			"TTL", 	"https://raw.githubusercontent.com/ikm-group/ArchiMEO/master/ARCHIMEO/NCO/NCO.ttl"),
//	BMM		("bmm",			"TTL", 	"https://raw.githubusercontent.com/ikm-group/ArchiMEO/master/ARCHIMEO/BMM/BMM.ttl");
	
	private String prefix;
	private String format;
	private String remoteURL;

	ONTOLOGY(String prefix, String format, String remoteURL) {
		this.prefix = prefix;
		this.format = format;
		this.remoteURL = remoteURL;
	}

	public String getRemoteURL() {
		return remoteURL;
	}

	public String getFormat() {
		return format;
	}

	public String getPrefix() {
		return prefix;
	}
}
