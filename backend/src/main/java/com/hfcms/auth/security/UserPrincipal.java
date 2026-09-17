package com.hfcms.auth.security;

import com.hfcms.users.entity.User;
import com.hfcms.users.entity.UserStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@Getter
@AllArgsConstructor
@Builder
public class UserPrincipal implements UserDetails {

    private final Long id;
    private final String email;
    private final String password;
    private final String fullName;
    private final String roleName;
    private final UserStatus status;
    private final Collection<? extends GrantedAuthority> authorities;

    public static UserPrincipal create(User user) {
        String roleName = user.getRole().getName();
        // Ensure standard ROLE_ prefix for Spring Security hasRole() evaluation
        String authority = roleName.startsWith("ROLE_") ? roleName : "ROLE_" + roleName;

        return UserPrincipal.builder()
                .id(user.getId())
                .email(user.getEmail())
                .password(user.getPasswordHash())
                .fullName(user.getFullName())
                .roleName(roleName)
                .status(user.getStatus())
                .authorities(Collections.singletonList(new SimpleGrantedAuthority(authority)))
                .build();
    }

    public static UserPrincipal createFromClaims(Long id, String email, String fullName, String roleName) {
        String authority = roleName != null && roleName.startsWith("ROLE_") ? roleName : (roleName != null ? "ROLE_" + roleName : "ROLE_STUDENT");
        return UserPrincipal.builder()
                .id(id)
                .email(email)
                .fullName(fullName)
                .roleName(roleName)
                .status(UserStatus.ACTIVE)
                .authorities(Collections.singletonList(new SimpleGrantedAuthority(authority)))
                .build();
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return status != UserStatus.SUSPENDED;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return status == UserStatus.ACTIVE;
    }
}
