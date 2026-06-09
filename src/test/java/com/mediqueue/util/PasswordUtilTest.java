package com.mediqueue.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class PasswordUtilTest {

    @Test
    void hashIsBcryptAndNotPlaintext() {
        String hash = PasswordUtil.hashPassword("secret123");
        assertNotEquals("secret123", hash);
        assertTrue(hash.startsWith("$2a$"), "should be a bcrypt hash");
    }

    @Test
    void checkPasswordAcceptsCorrectAndRejectsWrong() {
        String hash = PasswordUtil.hashPassword("correct-horse");
        assertTrue(PasswordUtil.checkPassword("correct-horse", hash));
        assertFalse(PasswordUtil.checkPassword("wrong-horse", hash));
    }

    @Test
    void checkPasswordHandlesNullsSafely() {
        assertFalse(PasswordUtil.checkPassword(null, "x"));
        assertFalse(PasswordUtil.checkPassword("x", null));
        assertFalse(PasswordUtil.checkPassword("x", "   "));
    }
}
