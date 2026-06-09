package com.mediqueue.util;

import org.mindrot.jbcrypt.BCrypt;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * PasswordUtil - BCrypt password hashing utility
 * MediQueue | SWE3024 Code Camp
 * Author: Tam Lik Herng (23093024)
 */
public class PasswordUtil {

    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    }

    public static boolean checkPassword(String plainPassword, String storedHash) {
        if (plainPassword == null || storedHash == null || storedHash.trim().isEmpty()) {
            return false;
        }

        if (isBCryptHash(storedHash)) {
            try {
                return BCrypt.checkpw(plainPassword, storedHash);
            } catch (IllegalArgumentException e) {
                return false;
            }
        }

        if (isLegacySha256Hash(storedHash)) {
            return MessageDigest.isEqual(
                    sha256Hex(plainPassword).getBytes(StandardCharsets.UTF_8),
                    storedHash.toLowerCase().getBytes(StandardCharsets.UTF_8));
        }

        return false;
    }

    public static boolean isLegacySha256Hash(String storedHash) {
        return storedHash != null && storedHash.matches("(?i)^[0-9a-f]{64}$");
    }

    private static boolean isBCryptHash(String storedHash) {
        return storedHash.matches("^\\$2[aby]\\$\\d{2}\\$.{53}$");
    }

    private static String sha256Hex(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 algorithm is not available.", e);
        }
    }
}
