package com.hfcms.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME_NAME = "BearerAuth";

    @Bean
    public OpenAPI hfcmsOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("HFCMS REST API")
                        .description("Hostel Facility Complaint Management System - AI Case Manager API Documentation")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("HFCMS Engineering Team")
                                .email("dev@hfcms.internal"))
                        .license(new License().name("Proprietary").url("https://hfcms.internal/license")))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME))
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME,
                                new SecurityScheme()
                                        .name(SECURITY_SCHEME_NAME)
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("Enter JWT Access Token to authorize API requests")));
    }
}
