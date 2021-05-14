---
title: "Java RSA SHA512 sign & verify"
date: 2021-05-14T20:51:28+07:00
tags: ["java", "RSA"]
draft: false
---

Idea: Generate a pool of signatures to sign & verify concurrently.


```java
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;


public class RSASignAndVerify {
    private static final int POOL = (2 << 6) - 1;
    private static final Signature[] signSignatures = new Signature[POOL];
    private static final Signature[] verifySignatures = new Signature[POOL];

    public RSASignAndVerify(String publicKeyPath, String privateKeyPath) {
        try {
            KeyFactory kf = KeyFactory.getInstance("RSA");

            PrivateKey privateKey = kf.generatePrivate(
                    new PKCS8EncodedKeySpec(executorAuthUtil.loadPem(
                            Files.newInputStream(Paths.get(privateKeyPath)))));

            PublicKey publicKey = kf.generatePublic(
                    new X509EncodedKeySpec(executorAuthUtil.loadPem(
                            Files.newInputStream(Paths.get(publicKeyPath)))));

            for (int i = 0; i < signSignatures.length; i++) {
                signSignatures[i] = Signature.getInstance("SHA512WithRSA");
                verifySignatures[i] = Signature.getInstance("SHA512WithRSA");
                signSignatures[i].initSign(privateKey);
                verifySignatures[i].initVerify(publicKey);
            }
        } catch (Exception e) {
            log.error("Init signature error", e);
        }
    }


    private static Signature getSignSignature() {
        int idx = (int) (Thread.currentThread().getId() & POOL);
        return signSignatures[idx];
    }

    private static Signature getVerifySignature() {
        int idx = (int) (Thread.currentThread().getId() & POOL);
        return verifySignatures[idx];
    }

    public boolean sign(byte[] data) {
        Signature signature = getSignSignature();
        synchronized (signature) {
            try {
                signature.update(data);
                var sign = new String(Base64.getEncoder().encode(signature.sign()));
                userNotification.setSign(sign);
                return true;
            } catch (Exception e) {
                return false;
            }
        }
    }

    public boolean verify(byte[] data, String sign) {
        Signature signature = getVerifySignature();
        synchronized (signature) {
            try {
                signature.update(data);
                var sign = Base64.getDecoder().decode(sign);
                return signature.verify(sign);
            } catch (Exception e) {
                return false;
            }
        }
    }
}
```
