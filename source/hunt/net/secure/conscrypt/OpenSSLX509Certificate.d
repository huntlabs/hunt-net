module hunt.net.secure.conscrypt.OpenSSLX509Certificate;

// // dfmt off
// version(WITH_HUNT_SECURITY):
// // dfmt on

// import hunt.security.cert.X509Certificate;
// import hunt.security.cert.Certificate;

// import hunt.security.Principal;
// import hunt.security.Provider;
// import hunt.security.x500.X500Principal;
// import hunt.security.x509;
// import hunt.security.Key;

// import hunt.collection;
// import hunt.Exceptions;

// import std.bigint;
// import std.datetime;

// /**
//  * An implementation of {@link X509Certificate} based on BoringSSL.
//  *
//  * @hide
//  */

// final class OpenSSLX509Certificate : X509Certificate {
//     // private static final long serialVersionUID = 1992239142393372128L;

//     // private final long mContext;
//     // private int mHashCode;

//     // private final Date notBefore;
//     // private final Date notAfter;

//     // this(long ctx) throws ParsingException {
//     //     mContext = ctx;
//     //     // The legacy X509 OpenSSL APIs don't validate ASN1_TIME structures until access, so
//     //     // parse them here because this is the only time we're allowed to throw ParsingException
//     //     notBefore = toDate(NativeCrypto.X509_get_notBefore(mContext, this));
//     //     notAfter = toDate(NativeCrypto.X509_get_notAfter(mContext, this));
//     // }

//     // // A non-throwing constructor used when we have already parsed the dates
//     // private OpenSSLX509Certificate(long ctx, Date notBefore, Date notAfter) {
//     //     mContext = ctx;
//     //     this.notBefore = notBefore;
//     //     this.notAfter = notAfter;
//     // }

//     // private static Date toDate(long asn1time) throws ParsingException {
//     //     Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
//     //     calendar.set(Calendar.MILLISECOND, 0);
//     //     NativeCrypto.ASN1_TIME_to_Calendar(asn1time, calendar);
//     //     return calendar.getTime();
//     // }

//     // static OpenSSLX509Certificate fromX509DerInputStream(InputStream is)
//     //         throws ParsingException {
//     //     @SuppressWarnings("resource")
//     //     final OpenSSLBIOInputStream bis = new OpenSSLBIOInputStream(is, true);

//     //     try {
//     //         final long certCtx = NativeCrypto.d2i_X509_bio(bis.getBioContext());
//     //         if (certCtx == 0) {
//     //             return null;
//     //         }
//     //         return new OpenSSLX509Certificate(certCtx);
//     //     } catch (Exception e) {
//     //         throw new ParsingException(e);
//     //     } finally {
//     //         bis.release();
//     //     }
//     // }

//     // static OpenSSLX509Certificate fromX509Der(byte[] encoded) {
//     //     try {
//     //         return new OpenSSLX509Certificate(NativeCrypto.d2i_X509(encoded));
//     //     } catch (ParsingException e) {
//     //         throw new CertificateEncodingException(e);
//     //     }
//     // }

//     // static List<OpenSSLX509Certificate> fromPkcs7DerInputStream(InputStream is)
//     //         throws ParsingException {
//     //     @SuppressWarnings("resource")
//     //     OpenSSLBIOInputStream bis = new OpenSSLBIOInputStream(is, true);

//     //     final long[] certRefs;
//     //     try {
//     //         certRefs = NativeCrypto.d2i_PKCS7_bio(bis.getBioContext(), NativeCrypto.PKCS7_CERTS);
//     //     } catch (Exception e) {
//     //         throw new ParsingException(e);
//     //     } finally {
//     //         bis.release();
//     //     }

//     //     if (certRefs is null) {
//     //         return Collections.emptyList();
//     //     }

//     //     final List<OpenSSLX509Certificate> certs = new ArrayList<OpenSSLX509Certificate>(
//     //             certRefs.length);
//     //     for (int i = 0; i < certRefs.length; i++) {
//     //         if (certRefs[i] == 0) {
//     //             continue;
//     //         }
//     //         certs.add(new OpenSSLX509Certificate(certRefs[i]));
//     //     }
//     //     return certs;
//     // }

//     // static OpenSSLX509Certificate fromX509PemInputStream(InputStream is)
//     //         throws ParsingException {
//     //     @SuppressWarnings("resource")
//     //     final OpenSSLBIOInputStream bis = new OpenSSLBIOInputStream(is, true);

//     //     try {
//     //         final long certCtx = NativeCrypto.PEM_read_bio_X509(bis.getBioContext());
//     //         if (certCtx == 0L) {
//     //             return null;
//     //         }
//     //         return new OpenSSLX509Certificate(certCtx);
//     //     } catch (Exception e) {
//     //         throw new ParsingException(e);
//     //     } finally {
//     //         bis.release();
//     //     }
//     // }

//     // static List<OpenSSLX509Certificate> fromPkcs7PemInputStream(InputStream is)
//     //         throws ParsingException {
//     //     @SuppressWarnings("resource")
//     //     OpenSSLBIOInputStream bis = new OpenSSLBIOInputStream(is, true);

//     //     final long[] certRefs;
//     //     try {
//     //         certRefs = NativeCrypto.PEM_read_bio_PKCS7(bis.getBioContext(),
//     //                 NativeCrypto.PKCS7_CERTS);
//     //     } catch (Exception e) {
//     //         throw new ParsingException(e);
//     //     } finally {
//     //         bis.release();
//     //     }

//     //     final List<OpenSSLX509Certificate> certs = new ArrayList<OpenSSLX509Certificate>(
//     //             certRefs.length);
//     //     for (int i = 0; i < certRefs.length; i++) {
//     //         if (certRefs[i] == 0) {
//     //             continue;
//     //         }
//     //         certs.add(new OpenSSLX509Certificate(certRefs[i]));
//     //     }
//     //     return certs;
//     // }

//     // static OpenSSLX509Certificate fromCertificate(Certificate cert)
//     //         throws CertificateEncodingException {
//     //     if (cert instanceof OpenSSLX509Certificate) {
//     //         return (OpenSSLX509Certificate) cert;
//     //     } else if (cert instanceof X509Certificate) {
//     //         return fromX509Der(cert.getEncoded());
//     //     } else {
//     //         throw new CertificateEncodingException("Only X.509 certificates are supported");
//     //     }
//     // }

//     // override
//     // Set<string> getCriticalExtensionOIDs() {
//     //     string[] critOids =
//     //             NativeCrypto.get_X509_ext_oids(mContext, this, NativeCrypto.EXTENSION_TYPE_CRITICAL);

//     //     /*
//     //      * This API has a special case that if there are no extensions, we
//     //      * should return null. So if we have no critical extensions, we'll check
//     //      * non-critical extensions.
//     //      */
//     //     if ((critOids.length == 0)
//     //             && (NativeCrypto.get_X509_ext_oids(mContext, this,
//     //                     NativeCrypto.EXTENSION_TYPE_NON_CRITICAL).length == 0)) {
//     //         return null;
//     //     }

//     //     return new HashSet<string>(Arrays.asList(critOids));
//     // }

//     // override
//     // byte[] getExtensionValue(string oid) {
//     //     return NativeCrypto.X509_get_ext_oid(mContext, this, oid);
//     // }

//     // override
//     // Set<string> getNonCriticalExtensionOIDs() {
//     //     string[] nonCritOids =
//     //             NativeCrypto.get_X509_ext_oids(mContext, this, NativeCrypto.EXTENSION_TYPE_NON_CRITICAL);

//     //     /*
//     //      * This API has a special case that if there are no extensions, we
//     //      * should return null. So if we have no non-critical extensions, we'll
//     //      * check critical extensions.
//     //      */
//     //     if ((nonCritOids.length == 0)
//     //             && (NativeCrypto.get_X509_ext_oids(mContext, this,
//     //                     NativeCrypto.EXTENSION_TYPE_CRITICAL).length == 0)) {
//     //         return null;
//     //     }

//     //     return new HashSet<string>(Arrays.asList(nonCritOids));
//     // }

//     // override
//     // boolean hasUnsupportedCriticalExtension() {
//     //     return (NativeCrypto.get_X509_ex_flags(mContext, this) & NativeConstants.EXFLAG_CRITICAL) != 0;
//     // }

//     // override
//     // void checkValidity() throws CertificateExpiredException,
//     //         CertificateNotYetValidException {
//     //     checkValidity(new Date());
//     // }

//     // override
//     // void checkValidity(Date date) throws CertificateExpiredException,
//     //         CertificateNotYetValidException {
//     //     if (getNotBefore().compareTo(date) > 0) {
//     //         throw new CertificateNotYetValidException("Certificate not valid until "
//     //                 + getNotBefore().toString() ~ " (compared to " ~ date.toString() ~ ")");
//     //     }

//     //     if (getNotAfter().compareTo(date) < 0) {
//     //         throw new CertificateExpiredException("Certificate expired at "
//     //                 + getNotAfter().toString() ~ " (compared to " ~ date.toString() ~ ")");
//     //     }
//     // }

//     // override
//     // int getVersion() {
//     //     return (int) NativeCrypto.X509_get_version(mContext, this) + 1;
//     // }

//     // override
//     // BigInteger getSerialNumber() {
//     //     return new BigInteger(NativeCrypto.X509_get_serialNumber(mContext, this));
//     // }

//     // override
//     // Principal getIssuerDN() {
//     //     return getIssuerX500Principal();
//     // }

//     // override
//     // Principal getSubjectDN() {
//     //     return getSubjectX500Principal();
//     // }

//     // override
//     // Date getNotBefore() {
//     //     return (Date) notBefore.clone();
//     // }

//     // override
//     // Date getNotAfter() {
//     //     return (Date) notAfter.clone();
//     // }

//     // override
//     // byte[] getTBSCertificate() throws CertificateEncodingException {
//     //     return NativeCrypto.get_X509_cert_info_enc(mContext, this);
//     // }

//     // override
//     // byte[] getSignature() {
//     //     return NativeCrypto.get_X509_signature(mContext, this);
//     // }

//     // override
//     // string getSigAlgName() {
//     //     string oid = getSigAlgOID();
//     //     string algName = Platform.oidToAlgorithmName(oid);
//     //     if (algName !is null) {
//     //         return algName;
//     //     }
//     //     return oid;
//     // }

//     // override
//     // string getSigAlgOID() {
//     //     return NativeCrypto.get_X509_sig_alg_oid(mContext, this);
//     // }

//     // override
//     // byte[] getSigAlgParams() {
//     //     return NativeCrypto.get_X509_sig_alg_parameter(mContext, this);
//     // }

//     // override
//     // boolean[] getIssuerUniqueID() {
//     //     return NativeCrypto.get_X509_issuerUID(mContext, this);
//     // }

//     // override
//     // boolean[] getSubjectUniqueID() {
//     //     return NativeCrypto.get_X509_subjectUID(mContext, this);
//     // }

//     // override
//     // boolean[] getKeyUsage() {
//     //     final boolean[] kusage = NativeCrypto.get_X509_ex_kusage(mContext, this);
//     //     if (kusage is null) {
//     //         return null;
//     //     }

//     //     if (kusage.length >= 9) {
//     //         return kusage;
//     //     }

//     //     final boolean[] resized = new boolean[9];
//     //     System.arraycopy(kusage, 0, resized, 0, kusage.length);
//     //     return resized;
//     // }

//     // override
//     // int getBasicConstraints() {
//     //     if ((NativeCrypto.get_X509_ex_flags(mContext, this) & NativeConstants.EXFLAG_CA) == 0) {
//     //         return -1;
//     //     }

//     //     final int pathLen = NativeCrypto.get_X509_ex_pathlen(mContext, this);
//     //     if (pathLen == -1) {
//     //         return int.MAX_VALUE;
//     //     }

//     //     return pathLen;
//     // }

//     // override
//     // byte[] getEncoded() throws CertificateEncodingException {
//     //     return NativeCrypto.i2d_X509(mContext, this);
//     // }

//     // private void verifyOpenSSL(OpenSSLKey pkey) throws CertificateException,
//     //                                                    NoSuchAlgorithmException,
//     //                                                    InvalidKeyException, SignatureException {
//     //     try {
//     //         NativeCrypto.X509_verify(mContext, this, pkey.getNativeRef());
//     //     } catch (RuntimeException e) {
//     //         throw new CertificateException(e);
//     //     } catch (BadPaddingException e) {
//     //         throw new SignatureException();
//     //     }
//     // }

//     // private void verifyInternal(PublicKey key, string sigProvider) throws CertificateException,
//     //         NoSuchAlgorithmException, InvalidKeyException, NoSuchProviderException,
//     //         SignatureException {
//     //     final Signature sig;
//     //     if (sigProvider is null) {
//     //         sig = Signature.getInstance(getSigAlgName());
//     //     } else {
//     //         sig = Signature.getInstance(getSigAlgName(), sigProvider);
//     //     }

//     //     sig.initVerify(key);
//     //     sig.update(getTBSCertificate());
//     //     if (!sig.verify(getSignature())) {
//     //         throw new SignatureException("signature did not verify");
//     //     }
//     // }

//     // override
//     // void verify(PublicKey key) throws CertificateException, NoSuchAlgorithmException,
//     //         InvalidKeyException, NoSuchProviderException, SignatureException {
//     //     if (key instanceof OpenSSLKeyHolder) {
//     //         OpenSSLKey pkey = ((OpenSSLKeyHolder) key).getOpenSSLKey();
//     //         verifyOpenSSL(pkey);
//     //         return;
//     //     }

//     //     verifyInternal(key, (string) null);
//     // }

//     // override
//     // void verify(PublicKey key, string sigProvider) throws CertificateException,
//     //         NoSuchAlgorithmException, InvalidKeyException, NoSuchProviderException,
//     //         SignatureException {
//     //     verifyInternal(key, sigProvider);
//     // }

//     // /* override */
//     // @SuppressWarnings("MissingOverride")  // For compilation with Java 7.
//     // // noinspection Override
//     // void verify(PublicKey key, Provider sigProvider)
//     //         throws CertificateException, NoSuchAlgorithmException, InvalidKeyException,
//     //                SignatureException {
//     //     if (key instanceof OpenSSLKeyHolder && sigProvider instanceof OpenSSLProvider) {
//     //         OpenSSLKey pkey = ((OpenSSLKeyHolder) key).getOpenSSLKey();
//     //         verifyOpenSSL(pkey);
//     //         return;
//     //     }

//     //     final Signature sig;
//     //     if (sigProvider is null) {
//     //         sig = Signature.getInstance(getSigAlgName());
//     //     } else {
//     //         sig = Signature.getInstance(getSigAlgName(), sigProvider);
//     //     }

//     //     sig.initVerify(key);
//     //     sig.update(getTBSCertificate());
//     //     if (!sig.verify(getSignature())) {
//     //         throw new SignatureException("signature did not verify");
//     //     }
//     // }

//     // override
//     // string toString() {
//     //     ByteArrayOutputStream os = new ByteArrayOutputStream();
//     //     long bioCtx = NativeCrypto.create_BIO_OutputStream(os);
//     //     try {
//     //         NativeCrypto.X509_print_ex(bioCtx, mContext, this, 0, 0);
//     //         return os.toString();
//     //     } finally {
//     //         NativeCrypto.BIO_free_all(bioCtx);
//     //     }
//     // }

//     // override
//     // PublicKey getPublicKey() {
//     //     /* First try to generate the key from supported OpenSSL key types. */
//     //     try {
//     //         OpenSSLKey pkey = new OpenSSLKey(NativeCrypto.X509_get_pubkey(mContext, this));
//     //         return pkey.getPublicKey();
//     //     } catch (NoSuchAlgorithmException ignored) {
//     //     } catch (InvalidKeyException ignored) {
//     //     }

//     //     /* Try generating the key using other Java providers. */
//     //     string oid = NativeCrypto.get_X509_pubkey_oid(mContext, this);
//     //     byte[] encoded = NativeCrypto.i2d_X509_PUBKEY(mContext, this);
//     //     try {
//     //         KeyFactory kf = KeyFactory.getInstance(oid);
//     //         return kf.generatePublic(new X509EncodedKeySpec(encoded));
//     //     } catch (NoSuchAlgorithmException ignored) {
//     //     } catch (InvalidKeySpecException ignored) {
//     //     }

//     //     /*
//     //      * We couldn't find anything else, so just return a nearly-unusable
//     //      * X.509-encoded key.
//     //      */
//     //     return new X509PublicKey(oid, encoded);
//     // }

//     // override
//     // X500Principal getIssuerX500Principal() {
//     //     final byte[] issuer = NativeCrypto.X509_get_issuer_name(mContext, this);
//     //     return new X500Principal(issuer);
//     // }

//     // override
//     // X500Principal getSubjectX500Principal() {
//     //     final byte[] subject = NativeCrypto.X509_get_subject_name(mContext, this);
//     //     return new X500Principal(subject);
//     // }

//     // override
//     // List<string> getExtendedKeyUsage() throws CertificateParsingException {
//     //     string[] extUsage = NativeCrypto.get_X509_ex_xkusage(mContext, this);
//     //     if (extUsage is null) {
//     //         return null;
//     //     }

//     //     return Arrays.asList(extUsage);
//     // }

//     // private static Collection<List<?>> alternativeNameArrayToList(Object[][] altNameArray) {
//     //     if (altNameArray is null) {
//     //         return null;
//     //     }

//     //     Collection<List<?>> coll = new ArrayList<List<?>>(altNameArray.length);
//     //     for (int i = 0; i < altNameArray.length; i++) {
//     //         coll.add(Collections.unmodifiableList(Arrays.asList(altNameArray[i])));
//     //     }

//     //     return Collections.unmodifiableCollection(coll);
//     // }

//     // override
//     // Collection<List<?>> getSubjectAlternativeNames() throws CertificateParsingException {
//     //     return alternativeNameArrayToList(NativeCrypto.get_X509_GENERAL_NAME_stack(mContext, this,
//     //             NativeCrypto.GN_STACK_SUBJECT_ALT_NAME));
//     // }

//     // override
//     // Collection<List<?>> getIssuerAlternativeNames() throws CertificateParsingException {
//     //     return alternativeNameArrayToList(NativeCrypto.get_X509_GENERAL_NAME_stack(mContext, this,
//     //             NativeCrypto.GN_STACK_ISSUER_ALT_NAME));
//     // }

//     // override
//     // boolean equals(Object other) {
//     //     if (other instanceof OpenSSLX509Certificate) {
//     //         OpenSSLX509Certificate o = (OpenSSLX509Certificate) other;

//     //         return NativeCrypto.X509_cmp(mContext, this, o.mContext, o) == 0;
//     //     }

//     //     return super.equals(other);
//     // }

//     // override
//     // int hashCode() {
//     //     if (mHashCode !is null) {
//     //         return mHashCode;
//     //     }
//     //     mHashCode = super.hashCode();
//     //     return mHashCode;
//     // }

//     // /**
//     //  * Returns the raw pointer to the X509 context for use in JNI calls. The
//     //  * life cycle of this native pointer is managed by the
//     //  * {@code OpenSSLX509Certificate} instance and must not be destroyed or
//     //  * freed by users of this API.
//     //  */
//     // long getContext() {
//     //     return mContext;
//     // }

//     // /**
//     //  * Delete an extension.
//     //  *
//     //  * A modified copy of the certificate is returned. The original object
//     //  * is unchanged.
//     //  * If the extension is not present, an unmodified copy is returned.
//     //  */
//     // OpenSSLX509Certificate withDeletedExtension(string oid) {
//     //     OpenSSLX509Certificate copy = new OpenSSLX509Certificate(NativeCrypto.X509_dup(mContext, this), notBefore, notAfter);
//     //     NativeCrypto.X509_delete_ext(copy.getContext(), copy, oid);
//     //     return copy;
//     // }

//     // override
//     // protected void finalize() {
//     //     try {
//     //         if (mContext != 0) {
//     //             NativeCrypto.X509_free(mContext, this);
//     //         }
//     //     } finally {
//     //         super.finalize();
//     //     }
//     // }
// }

