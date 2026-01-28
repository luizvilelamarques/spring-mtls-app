package com.exemplo.mtls;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class MtlsApplication {
    public static void main(String[] args) {
        SpringApplication.run(MtlsApplication.class, args);
    }

    @GetMapping("/hello")
    public String hello() {
        return "Conexão mTLS estabelecida com sucesso!";
    }
}