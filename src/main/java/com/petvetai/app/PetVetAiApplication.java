package com.petvetai.app;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.petvetai.app.mapper")
public class PetVetAiApplication {

	public static void main(String[] args) {
		SpringApplication.run(PetVetAiApplication.class, args);
	}

}
