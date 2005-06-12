package Crypt::X509;

use strict;
use Carp;
use Convert::ASN1 qw(:io :debug);

our $VERSION = '0.01';

=head1 NAME

Crypt::X509 - Parses an X.509 certificate

=head1 SYNOPSIS

 use Crypt::X509;

 $cert = Crypt::X509->new( cert => $cert );

 $subject_email	= $cert->subject_email;

=cut

=head1 REQUIRES

Convert::ASN1

=head1 DESCRIPTION

B<Crypt::X509> parses X.509 certificates. Methods are provided for accessing most
certificate elements.

=cut

#########################################################################
# constructor
#########################################################################

=head1 CONSTRUCTOR

=over 4

=item new ( OPTIONS )

Creates and returns a parsed X.509 certificate object.

=over 4

=item cert =E<gt> $certificate

A variable containing the DER formatted certificate to be parsed.

=cut back

sub new {
	my ($class, %args) = @_;

	my $self = _decode($args{'cert'});

	return bless($self, $class);
}


#########################################################################
# accessors - general items
#########################################################################

=head1 METHODS

=over 4

=item pubkey_algorithm ( )

Returns the algorithm which the public key was created with.

=cut back

sub pubkey_algorithm {
	my $self = shift;
	return $self->{tbsCertificate}{subjectPublicKeyInfo}{algorithm}{algorithm};
}


=item pubkey ( )

Returns the certificate's public key in DER format.

=cut back

sub pubkey {
	my $self = shift;
	return $self->{tbsCertificate}{subjectPublicKeyInfo}{subjectPublicKey}[0];
}


=item version ( )

Returns the certificate's version.

=cut back

sub version {
	my $self = shift;
	return $self->{tbsCertificate}{version};
}


=item serial ( )

Returns the certificate's serial number.

=cut back

sub serial {
	my $self = shift;
	return $self->{tbsCertificate}{serialNumber};
}


=item sig_algorithm ( )

Returns the certificate's signature algorithm.

=cut back

sub sig_algorithm {
	my $self = shift;
	return $self->{tbsCertificate}{signature}{algorithm};
}


=item not_before ( )

Returns the certificate's beginning date of validity.

=cut back

sub not_before {
	my $self = shift;
	return $self->{tbsCertificate}{validity}{notBefore}{utcTime};
}


=item not_after ( )

Returns the certificate's ending date of validity.

=cut back

sub not_after {
	my $self = shift;
	return $self->{tbsCertificate}{validity}{notAfter}{utcTime};
}


=item signature ( )

Return's the certificate's signature in DER format.

=cut back

sub signature {
	my $self = shift;
	# should base64_encode() before returning?
	return $self->{signature}[0];
}


#=item sig_algorithm ( )
#
#Return's the certificate's signature algorithm.
#
#=cut back
#
#sub sig_algorithm {
#	my $self = shift;
#	return $self->{signatureAlgorithm}{algorithm};
#}


#########################################################################
# accessors - subject
#########################################################################

=item subject_country ( )

Returns the subject's country.

=cut back

sub subject_country {
	my $self = shift;
	return $self->{tbsCertificate}{subject}{rdnSequence}[0][0]{value}{printableString};
}


=item subject_state ( )

Returns the subject's state or province.

=cut back

sub subject_state {
	my $self = shift;
	return $self->{tbsCertificate}{subject}{rdnSequence}[1][0]{value}{printableString};
}


=item subject_org ( )

Returns the subject's organization.

=cut back

sub subject_org {
	my $self = shift;
	return $self->{tbsCertificate}{subject}{rdnSequence}[2][0]{value}{printableString};
}


=item subject_ou ( )

Returns the subject's organizational unit.

=cut back

sub subject_ou {
	my $self = shift;
	return $self->{tbsCertificate}{subject}{rdnSequence}[3][0]{value}{printableString};
}


=item subject_cn ( )

Returns the subject's common name.

=cut back

sub subject_cn {
	my $self = shift;
	return $self->{tbsCertificate}{subject}{rdnSequence}[4][0]{value}{printableString};
}


=item subject_email ( )

Returns the subject's email address.

=cut back

sub subject_email {
	my $self = shift;
	return $self->{tbsCertificate}{subject}{rdnSequence}[5][0]{value}{ia5String};
}


#########################################################################
# accessors - issuer
#########################################################################

=item issuer_cn ( )

Returns the issuer's common name.

=cut back

sub issuer_cn {
	my $self = shift;
	return $self->{tbsCertificate}{issuer}{rdnSequence}[0][0]{value}{printableString};
}


=item issuer_country ( )

Returns the issuer's country.

=cut back

sub issuer_country {
	my $self = shift;
	return $self->{tbsCertificate}{issuer}{rdnSequence}[1][0]{value}{printableString};
}


=item issuer_state ( )

Returns the issuer's state or province.

=cut back

sub issuer_state {
	my $self = shift;
	return $self->{tbsCertificate}{issuer}{rdnSequence}[2][0]{value}{printableString};
}


=item issuer_locality ( )

Returns the issuer's locality.

=cut back

sub issuer_locality {
	my $self = shift;
	return $self->{tbsCertificate}{issuer}{rdnSequence}[3][0]{value}{printableString};
}


=item issuer_org ( )

Returns the issuer's organization.

=cut back

sub issuer_org {
	my $self = shift;
	return $self->{tbsCertificate}{issuer}{rdnSequence}[4][0]{value}{printableString};
}


=item issuer_email ( )

Returns the issuer's email address.

=cut back

sub issuer_email {
	my $self = shift;
	return $self->{tbsCertificate}{issuer}{rdnSequence}[5][0]{value}{ia5String};
}


#########################################################################
# accessors - extensions (automate this)
#########################################################################
#sub {
#	# method - $decode->;
#	print "extnID [0]: $cert->{tbsCertificate}{extensions}[0]{extnID}\n";
#}
#
#sub {
#	# method - $decode->;
#	print "extnID [1]: $cert->{tbsCertificate}{extensions}[1]{extnID}\n";
#}


=item authority_serial ( )

Returns the authority's certificate serial number.

=cut back

sub authority_serial {
	my $self = shift;
	return $self->{tbsCertificate}{extensions}[2]{extnValue}{authorityCertSerialNumber};
}


=item key_identifier ( )

Returns the key identifier.

=cut back

sub key_identifier {
	my $self = shift;
	return $self->{tbsCertificate}{extensions}[2]{extnValue}{keyIdentifier};
}


#########################################################################
# accessors - authorityCertIssuer
#########################################################################

=item authority_ca ( )

Returns the authority's ca.

=cut back

sub authority_ca {
	my $self = shift;
	return $self->{tbsCertificate}{extensions}[2]{extnValue}{authorityCertIssuer}[0]{directoryName}{rdnSequence}->[0][0]{value}{printableString};
}


=item authority_country ( )

Returns the authority's country.

=cut back

sub authority_country {
	my $self = shift;
	return $self->{tbsCertificate}{extensions}[2]{extnValue}{authorityCertIssuer}[0]{directoryName}{rdnSequence}->[1][0]{value}{printableString};
}


=item authority_state ( )

Returns the authority's state.

=cut back

sub authority_state {
	my $self = shift;
	return $self->{tbsCertificate}{extensions}[2]{extnValue}{authorityCertIssuer}[0]{directoryName}{rdnSequence}->[2][0]{value}{printableString};
}


=item authority_locality ( )

Returns the authority's locality.

=cut back

sub authority_locality {
	my $self = shift;
	return $self->{tbsCertificate}{extensions}[2]{extnValue}{authorityCertIssuer}[0]{directoryName}{rdnSequence}->[3][0]{value}{printableString};
}


=item authority_org ( )

Returns the authority's organization.

=cut back

sub authority_org {
	my $self = shift;
	return $self->{tbsCertificate}{extensions}[2]{extnValue}{authorityCertIssuer}[0]{directoryName}{rdnSequence}->[4][0]{value}{printableString};
}


=item authority_email ( )

Returns the authority's email.

=cut back

sub authority_email {
	my $self = shift;
	return $self->{tbsCertificate}{extensions}[2]{extnValue}{authorityCertIssuer}[0]{directoryName}{rdnSequence}[5][0]{value}{ia5String};
}


=item authority_crl ( )

Returns the authority's crl in DER format.

=cut back

sub authority_crl {
	my $self = shift;
	return $self->{tbsCertificate}{extensions}[3]{extnValue}{ia5String};
}


#######################################################################
# internal functions
#######################################################################
sub _decode {
  my $der_cert		= shift;

  my $asn		= _x509_ASN();
  my $asn_BitString	= Convert::ASN1->new();
  my $asn_OctetString	= Convert::ASN1->new();

  $asn_BitString->prepare("bitString BIT STRING");
  $asn_OctetString->prepare("octetString OCTET STRING");

  my $asn_cert	= $asn->find('Certificate');
  my $cert	= $asn_cert->decode($der_cert) || carp "asn decode error: ". $asn_cert->error;
	
  # decoders for extensions
  my %extnoid2asn = (
	'2.5.29.9'		=> $asn->find('SubjectDirectoryAttributes'),
	'2.5.29.14'		=> $asn_OctetString,		# SubjectKeyIdentifier
	'2.5.29.15'		=> $asn_BitString,	  	# keyUsage

	'2.5.29.16'		=> $asn->find('PrivateKeyUsagePeriod'),
	'2.5.29.17'		=> $asn->find('SubjectAltName'),
	'2.5.29.18'		=> $asn->find('IssuerAltName'),
	'2.5.29.19'		=> $asn->find('BasicConstraints'),
	'2.5.29.30'		=> $asn->find('NameConstraints'),
	'2.5.29.31'		=> $asn->find('cRLDistributionPoints'),
	'2.5.29.32'		=> $asn->find('CertificatePolicies'),
	'2.5.29.33'		=> $asn->find('PolicyMappings'),
	'2.5.29.35'		=> $asn->find('AuthorityKeyIdentifier'),
	'2.5.29.36'		=> $asn->find('PolicyConstraints'),
	'2.5.29.37'		=> $asn->find('ExtKeyUsageSyntax'),

	'2.16.840.1.113730.1.1'	=> $asn_BitString,		            # netscape-cert-type 

	'2.16.840.1.113730.1.2'	=> $asn->find('DirectoryString'), # netscape-base-url 
	'2.16.840.1.113730.1.3'	=> $asn->find('DirectoryString'), # netscape-revocation-url 
	'2.16.840.1.113730.1.4'	=> $asn->find('DirectoryString'), # netscape-ca-revocation-url 
	'2.16.840.1.113730.1.7'	=> $asn->find('DirectoryString'), # netscape-cert-renewal-url
	'2.16.840.1.113730.1.8'	=> $asn->find('DirectoryString'), # netscape-ca-policy-url
	'2.16.840.1.113730.1.12'=> $asn->find('DirectoryString'), # netscape-ssl-server-name
	'2.16.840.1.113730.1.13'=> $asn->find('DirectoryString'), # netscape-comment
  );

  foreach my $extension ( @{$cert->{'tbsCertificate'}->{'extensions'}} ) {

    if ( exists $extnoid2asn{$extension->{'extnID'}} ) {

      $extension->{'extnValue'} =
        ($extnoid2asn{$extension->{'extnID'}})->decode( $extension->{'extnValue'} );

    } else {
#      print STDERR "unknown ", 
#
#      $extension->{'critical'} ? "critical "
#        : "", "extension: ", $extension->{'extnID'}, "\n";

      asn_dump( $extension->{'extnValue'} );
    }
  }

  return $cert;
}

sub _x509_ASN {
	my $asn = Convert::ASN1->new;

	$asn->prepare(<<ASN1) || carp "asn prepare error: ", $asn->error;
-- ASN.1 from RFC2459 and X.509(2001)
-- Adapted for use with Convert::ASN1

-- attribute data types --

Attribute ::= SEQUENCE {
	type			AttributeType,
	values			SET OF AttributeValue
		-- at least one value is required -- 
	}

AttributeType ::= OBJECT IDENTIFIER

AttributeValue ::= DirectoryString  --ANY 

AttributeTypeAndValue ::= SEQUENCE {
	type			AttributeType,
	value			AttributeValue
	}


-- naming data types --

Name ::= CHOICE { -- only one possibility for now 
	rdnSequence		RDNSequence 			
	}

RDNSequence ::= SEQUENCE OF RelativeDistinguishedName

DistinguishedName ::= RDNSequence

RelativeDistinguishedName ::= 
	SET OF AttributeTypeAndValue  --SET SIZE (1 .. MAX) OF


-- Directory string type --

DirectoryString ::= CHOICE {
	teletexString		TeletexString,  --(SIZE (1..MAX)),
	printableString		PrintableString,  --(SIZE (1..MAX)),
	bmpString		BMPString,  --(SIZE (1..MAX)),
	universalString		UniversalString,  --(SIZE (1..MAX)),
	utf8String		UTF8String,  --(SIZE (1..MAX)),
	ia5String		IA5String  --added for EmailAddress
	}


-- certificate and CRL specific structures begin here

Certificate ::= SEQUENCE  {
	tbsCertificate		TBSCertificate,
	signatureAlgorithm	AlgorithmIdentifier,
	signature		BIT STRING
	}

TBSCertificate  ::=  SEQUENCE  {
	version		    [0] EXPLICIT Version OPTIONAL,  --DEFAULT v1
	serialNumber		CertificateSerialNumber,
	signature		AlgorithmIdentifier,
	issuer			Name,
	validity		Validity,
	subject			Name,
	subjectPublicKeyInfo	SubjectPublicKeyInfo,
	issuerUniqueID	    [1] IMPLICIT UniqueIdentifier OPTIONAL,
		-- If present, version shall be v2 or v3
	subjectUniqueID	    [2] IMPLICIT UniqueIdentifier OPTIONAL,
		-- If present, version shall be v2 or v3
	extensions	    [3] EXPLICIT Extensions OPTIONAL
		-- If present, version shall be v3
	}

Version ::= INTEGER  --{  v1(0), v2(1), v3(2)  }

CertificateSerialNumber ::= INTEGER

Validity ::= SEQUENCE {
	notBefore		Time,
	notAfter		Time
	}

Time ::= CHOICE {
	utcTime			UTCTime,
	generalTime		GeneralizedTime
	}

UniqueIdentifier ::= BIT STRING

SubjectPublicKeyInfo ::= SEQUENCE {
	algorithm		AlgorithmIdentifier,
	subjectPublicKey	BIT STRING
	}

Extensions ::= SEQUENCE OF Extension  --SIZE (1..MAX) OF Extension

Extension ::= SEQUENCE {
	extnID			OBJECT IDENTIFIER,
	critical		BOOLEAN OPTIONAL,  --DEFAULT FALSE,
	extnValue		OCTET STRING
	}

AlgorithmIdentifier ::= SEQUENCE {
	algorithm		OBJECT IDENTIFIER,
	parameters		ANY
	}


--extensions

AuthorityKeyIdentifier ::= SEQUENCE {
      keyIdentifier             [0] KeyIdentifier            OPTIONAL,
      authorityCertIssuer       [1] GeneralNames             OPTIONAL,
      authorityCertSerialNumber [2] CertificateSerialNumber  OPTIONAL }
    -- authorityCertIssuer and authorityCertSerialNumber shall both
    -- be present or both be absent

KeyIdentifier ::= OCTET STRING

SubjectKeyIdentifier ::= KeyIdentifier


-- key usage extension OID and syntax
-- id-ce-keyUsage OBJECT IDENTIFIER ::=  { id-ce 15 }

KeyUsage ::= BIT STRING --{
--      digitalSignature        (0),
--      nonRepudiation          (1),
--      keyEncipherment         (2),
--      dataEncipherment        (3),
--      keyAgreement            (4),
--      keyCertSign             (5),
--      cRLSign                 (6),
--      encipherOnly            (7),
--      decipherOnly            (8) }


-- private key usage period extension OID and syntax
-- id-ce-privateKeyUsagePeriod OBJECT IDENTIFIER ::=  { id-ce 16 }

PrivateKeyUsagePeriod ::= SEQUENCE {
     notBefore       [0]     GeneralizedTime OPTIONAL,
     notAfter        [1]     GeneralizedTime OPTIONAL }
     -- either notBefore or notAfter shall be present


-- certificate policies extension OID and syntax
-- id-ce-certificatePolicies OBJECT IDENTIFIER ::=  { id-ce 32 }

CertificatePolicies ::= SEQUENCE OF PolicyInformation

PolicyInformation ::= SEQUENCE {
     policyIdentifier   CertPolicyId,
     policyQualifiers   SEQUENCE OF
             PolicyQualifierInfo } --OPTIONAL }

CertPolicyId ::= OBJECT IDENTIFIER

PolicyQualifierInfo ::= SEQUENCE {
       policyQualifierId  PolicyQualifierId,
       qualifier        ANY } --DEFINED BY policyQualifierId }

-- Implementations that recognize additional policy qualifiers shall
-- augment the following definition for PolicyQualifierId

PolicyQualifierId ::=
     OBJECT IDENTIFIER --( id-qt-cps | id-qt-unotice )

-- CPS pointer qualifier

CPSuri ::= IA5String

-- user notice qualifier

UserNotice ::= SEQUENCE {
     noticeRef        NoticeReference OPTIONAL,
     explicitText     DisplayText OPTIONAL}

NoticeReference ::= SEQUENCE {
     organization     DisplayText,
     noticeNumbers    SEQUENCE OF INTEGER }

DisplayText ::= CHOICE {
     visibleString    VisibleString  ,
     bmpString        BMPString      ,
     utf8String       UTF8String      }


-- policy mapping extension OID and syntax
-- id-ce-policyMappings OBJECT IDENTIFIER ::=  { id-ce 33 }

PolicyMappings ::= SEQUENCE OF SEQUENCE {
     issuerDomainPolicy      CertPolicyId,
     subjectDomainPolicy     CertPolicyId }


-- subject alternative name extension OID and syntax
-- id-ce-subjectAltName OBJECT IDENTIFIER ::=  { id-ce 17 }

SubjectAltName ::= GeneralNames

GeneralNames ::= SEQUENCE OF GeneralName

GeneralName ::= CHOICE {
     otherName                       [0]     AnotherName,
     rfc822Name                      [1]     IA5String,
     dNSName                         [2]     IA5String,
     x400Address                     [3]     ANY, --ORAddress,
     directoryName                   [4]     Name,
     ediPartyName                    [5]     EDIPartyName,
     uniformResourceIdentifier       [6]     IA5String,
     iPAddress                       [7]     OCTET STRING,
     registeredID                    [8]     OBJECT IDENTIFIER }

-- AnotherName replaces OTHER-NAME ::= TYPE-IDENTIFIER, as
-- TYPE-IDENTIFIER is not supported in the '88 ASN.1 syntax

AnotherName ::= SEQUENCE {
     type    OBJECT IDENTIFIER,
     value      [0] EXPLICIT ANY } --DEFINED BY type-id }

EDIPartyName ::= SEQUENCE {
     nameAssigner            [0]     DirectoryString OPTIONAL,
     partyName               [1]     DirectoryString }


-- issuer alternative name extension OID and syntax
-- id-ce-issuerAltName OBJECT IDENTIFIER ::=  { id-ce 18 }

IssuerAltName ::= GeneralNames


-- id-ce-subjectDirectoryAttributes OBJECT IDENTIFIER ::=  { id-ce 9 }

SubjectDirectoryAttributes ::= SEQUENCE OF Attribute


-- basic constraints extension OID and syntax
-- id-ce-basicConstraints OBJECT IDENTIFIER ::=  { id-ce 19 }

BasicConstraints ::= SEQUENCE {
     cA                      BOOLEAN OPTIONAL, --DEFAULT FALSE,
     pathLenConstraint       INTEGER OPTIONAL }


-- name constraints extension OID and syntax
-- id-ce-nameConstraints OBJECT IDENTIFIER ::=  { id-ce 30 }

NameConstraints ::= SEQUENCE {
     permittedSubtrees       [0]     GeneralSubtrees OPTIONAL,
     excludedSubtrees        [1]     GeneralSubtrees OPTIONAL }

GeneralSubtrees ::= SEQUENCE OF GeneralSubtree

GeneralSubtree ::= SEQUENCE {
     base                    GeneralName,
     minimum         [0]     BaseDistance OPTIONAL, --DEFAULT 0,
     maximum         [1]     BaseDistance OPTIONAL }

BaseDistance ::= INTEGER 


-- policy constraints extension OID and syntax
-- id-ce-policyConstraints OBJECT IDENTIFIER ::=  { id-ce 36 }

PolicyConstraints ::= SEQUENCE {
     requireExplicitPolicy           [0] SkipCerts OPTIONAL,
     inhibitPolicyMapping            [1] SkipCerts OPTIONAL }

SkipCerts ::= INTEGER 


-- CRL distribution points extension OID and syntax
-- id-ce-cRLDistributionPoints     OBJECT IDENTIFIER  ::=  {id-ce 31}

cRLDistributionPoints  ::= SEQUENCE OF DistributionPoint

DistributionPoint ::= SEQUENCE {
     distributionPoint       [0]     DistributionPointName OPTIONAL,
     reasons                 [1]     ReasonFlags OPTIONAL,
     cRLIssuer               [2]     GeneralNames OPTIONAL }

DistributionPointName ::= CHOICE {
     fullName                [0]     GeneralNames,
     nameRelativeToCRLIssuer [1]     RelativeDistinguishedName }

ReasonFlags ::= BIT STRING --{
--     unused                  (0),
--     keyCompromise           (1),
--     cACompromise            (2),
--     affiliationChanged      (3),
--     superseded              (4),
--     cessationOfOperation    (5),
--     certificateHold         (6),
--     privilegeWithdrawn      (7),
--     aACompromise            (8) }


-- extended key usage extension OID and syntax
-- id-ce-extKeyUsage OBJECT IDENTIFIER ::= {id-ce 37}

ExtKeyUsageSyntax ::= SEQUENCE OF KeyPurposeId

KeyPurposeId ::= OBJECT IDENTIFIER

-- extended key purpose OIDs
-- id-kp-serverAuth      OBJECT IDENTIFIER ::= { id-kp 1 }
-- id-kp-clientAuth      OBJECT IDENTIFIER ::= { id-kp 2 }
-- id-kp-codeSigning     OBJECT IDENTIFIER ::= { id-kp 3 }
-- id-kp-emailProtection OBJECT IDENTIFIER ::= { id-kp 4 }
-- id-kp-ipsecEndSystem  OBJECT IDENTIFIER ::= { id-kp 5 }
-- id-kp-ipsecTunnel     OBJECT IDENTIFIER ::= { id-kp 6 }
-- id-kp-ipsecUser       OBJECT IDENTIFIER ::= { id-kp 7 }
-- id-kp-timeStamping    OBJECT IDENTIFIER ::= { id-kp 8 }
ASN1

	return $asn;
}

=head1 ACKNOWLEDGEMENTS

This module is based on the x509decode script, which was contributed to
Convert::ASN1 in 2002 by Norbert Klasen.

=head1 AUTHOR

Mike Jackson <mj@sci.fi>

=head1 COPYRIGHT

Copyright (c) 2005 Mike Jackson <mj@sci.fi>.
Copyright (c) 2001-2002 Norbert Klasen, DAASI International GmbH.

All rights reserved. This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

1;
