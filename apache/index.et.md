# Ubuntu Apache2 veebiserveri kahepoolse SSLi häälestus Eesti ID‑kaartide vaates

**[In English](index.md)**

**Versioon:** 26.04/1

**Väljaandja:** [RIA](https://www.ria.ee/)

**Versiooni info**

| Kuupäev    | Versioon | Muutused/märkused
|:-----------|:--------:|:-----------------------------------------------------------
| 06.02.2019 | 19.02/1  | Avalik versioon.
| 20.02.2019 | 19.02/1  | Lisatud võimalike lisakonfiguratsioonide peatükk: tulemüüri ja OCSP seadistus ning vaikimisi veebilehe eemaldamine. — Muutja: Urmas Vanem
| 12.12.2019 | 19.12/1  | Lisatud Apache soovituslikud turvasätted. — Muutja: Urmas Vanem
| 16.12.2020 | 20.12/1  | Lisatud kasutajasertifikaadile nõue omada korrektset `extendedKeyUsage` välja ja õiget sertifikaadi väljastajat. Vt. peatükk „Kasutajasertifikaatide lisafiltreerimine". — Muutja: Urmas Vanem
| 17.12.2020 | 20.12/2  | Lisatud direktiiv `SSLCADNRequestPath`, vt. peatükk „Kasutajale kuvatavate sertifikaatide filtreerimine". — Muutja: Urmas Vanem
| 13.01.2021 | 21.01/1  | Lisatud demo-konfiguratsiooni fail lingina. Lisatud HSTS konfiguratsioon. — Muutja: Urmas Vanem
| 21.01.2021 | 21.01/2  | Parandatud `SSLOCSPEnable` parameeter: `on`->`leaf`. Uuendatud TLS 1.2 *cipher*te ja TLS protokollide kasutamise soovitused. Demokonfi ja dokumendi muutujate nimed on sünkroniseeritud. — Muutja: Urmas Vanem
| 27.01.2021 | 21.01/3  | Lisatud mobiil-ID filter. — Muutja: Urmas Vanem
| 26.02.2021 | 21.02/1  | Lisatud alternatiivne kesktaseme sertifitseerimiskeskuste filtreerimisvõimalus `SSLCADNRequestFile` direktiivi abil. — Muutja: Urmas Vanem
| 27.04.2021 | 21.04/1  | Eemaldatud aegunud `ESTEID-SK 2011` sertifikaatide tugi. — Muutja: Urmas Vanem
| 25.11.2021 | 21.11/1  | Ubuntu uuendatud versioonile Ubuntu Server 21.10 ja Apache versioonile 2.4.48. Lisatud ECC sertifikaatide loomine veebiserveril. Täiendatud TLS ja Cipher soovitusi. — Muutja: Urmas Vanem
| 21.02.2023 | 23.02/1  | Ubuntu uuendatud versioonile Ubuntu Server 22.04 ja Apache versioonile 2.4.55. Uuendatud virtuaalhosti konfiguratsiooni. — Muutja: Urmas Vanem
| 27.12.2023 | 23.12/1  | Eemaldatud `ESTEID-SK 2015` ahel. — Muutja: Urmas Vanem
| 27.12.2023 | 23.12/2  | Eemaldatud aegunud OCSP responderi sertifikaat. — Muutja: Urmas Vanem
| 22.08.2024 | 24.08/1  | Ubuntu uuendatud versioonile Ubuntu Server 24.04 ja Apache versioonile 2.4.62. — Muutja: Urmas Vanem
| 31.10.2025 | 25.10/1  | Lisatud Zetes ahelad. — Muutja: Raul Kaidro
| 22.04.2026 | 26.04/1  | Konverteeritud Markdown formaati. — Muutja: Raul Metsma

---

- TOC
{:toc}

## Sissejuhatus

Käesolevas juhendis kirjeldatakse:

- Kuidas paigaldada ja häälestada Apache2 (v. 2.4.66) veebiserver Ubuntu
  24.04 serveril.
- Kuidas häälestada HTTPS (ühepoolne SSL) veebiserveril.
- Kuidas häälestada [SK ID Solutions](https://www.skidsolutions.eu/resources/certificates/) (`EE-GovCA2018`) ja [Zetes](https://repository.eidpki.ee/) (`EEGovCA2025`) ID-kaartidega autentimine (kahepoolne SSL) veebiserveril.
- Muud võimalused serveri konfigureerimiseks ja soovitused turvalisuse
  tagamiseks.

## Apache2 paigaldus ja häälestus

### Paigaldus

1.  Uuenda Ubuntu pakkide andmed terminalis käsuga:

    ```bash
    $ apt update
    Hit:1 http://ee.archive.ubuntu.com/ubuntu noble InRelease
    Hit:2 http://ee.archive.ubuntu.com/ubuntu noble-updates InRelease
    Hit:3 http://ee.archive.ubuntu.com/ubuntu noble-backports InRelease
    Get:4 http://ee.archive.ubuntu.com/ubuntu noble/main Icons (48x48) [106 kB]
    Hit:5 http://security.ubuntu.com/ubuntu noble-security InRelease
    Get:6 http://ee.archive.ubuntu.com/ubuntu noble/main Icons (64x64) [156 kB]
    Get:7 http://ee.archive.ubuntu.com/ubuntu noble/main Icons (64x64@2) [21.8 kB]
    Get:8 http://ee.archive.ubuntu.com/ubuntu noble/universe Icons (48x48) [3,717 kB]
    ```

2.  Paigalda Apache2 käsuga:

    ```bash
    $ apt install apache2
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    The following additional packages will be installed:
      apache2-bin apache2-data apache2-utils libapr1t64 libaprutil1-dbd-sqlite3
      libaprutil1-ldap libaprutil1t64
    Suggested packages:
      apache2-doc apache2-suexec-pristine | apache2-suexec-custom
    ```

Eelneva tegevuse tulemusena on Apache server paigaldatud[^1].

```bash
$ apache2 -v
Server version: Apache/2.4.58 (Ubuntu)
Server built:   2025-08-11T11:10:09
```

Uuenda Apache versioonile 2.4.66, järgmiste käskude abil saad seda teha:

```bash
add-apt-repository ppa:ondrej/apache2
apt update
apt upgrade
```

Nüüd on Apache versiooniks ootuspäraselt 2.4.66:

```bash
$ apache2 -v
Server version: Apache/2.4.66 (Ubuntu)
Server built:   2025-07-26T17:41:22
```

Versiooniga 2.4.66 töötab Apache2 veebiserver nüüd ebaturvalises http
režiimis:

![Apache veebiserver vaikimisi konfiguratsioonis](./img/image1.png)

### Konfiguratsioon

#### Ühepoolse SSLi lubamine

Luba Apache serveril SSL mooduli käsuga `a2enmod ssl` ja taaskäivita Apache2 teenus käsuga `systemctl restart apache2`

```bash
$ a2enmod ssl
Considering dependency mime for ssl:
Module mime already enabled
Considering dependency socache_shmcb for ssl:
Enabling module socache_shmcb.
Enabling module ssl.
See /usr/share/doc/apache2/README.Debian.gz on how to configure SSL and create self-signed certificates.
To activate the new configuration, you need to run:
  systemctl restart apache2
$ systemctl restart apache2
```

##### SSL sertifikaadi privaatvõtme ja päringufaili (CSR) loomine

###### ECC (*Elliptic Curve Cryptography*)

Esmalt tuleb luua ECC algoritmil baseeruv privaatvõti ja seejärel privaatvõtme baasil sertifikaadi päringufail[^2]:

```bash
$ openssl ecparam -name secp384r1 -genkey -noout -out Apache2404.key
$ openssl req -new -key Apache2404.key -out Apache2404.csr -subj /C=EE/O=OctoX/CN=Apache2404.octox.demo -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:Apache2404.octox.demo,DNS:MYWEBSERVER.octox.demo"))
```

1.  `Apache2404.key` on sertifikaadi privaatvõti;
2.  `Apache2404.csr` on sertifikaadi päringufail, mis edastatakse
    sertifitseerimiskeskusele;

3.  `CN=Apache2404.octox.demo` on väljastatava sertifikaadi *common name;*
4.  `DNS:Apache2404.octox.demo` ja `DNS:MYWEBSERVER.octox.demo` on
    sertifikaadil olevad SAN DNS nimed, mis peavad kindlasti vastama
    veebilehe tegelikule aadressile[^3]. Need nimed peavad ka
    nimeserveris lahenema.

Loodud sertifikaadi päringufaili sisu on võimalik vaadata käsuga

```bash
$ openssl req -in Apache2404.csr -noout -text
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: C = EE, O = OctoX, CN = Apache2404.octox.demo
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (384 bit)
                pub:
                    04:db:9b:fe:8c:11:87:00:b1:71:9b:54:06:3a:49:
                    71:b0:89:04:dc:a9:75:52:54:42:39:07:21:84:51:
                    b7:5b:07:61:09:5b:e7:82:ff:60:58:b3:af:5e:73:
                    ee:03:47:1d:9d:26:e6:fe:92:e0:60:df:71:23:8e:
                    24:2b:11:be:68:f6:08:6c:3e:be:dc:7d:f4:32:6e:
                    9e:ae:5e:73:5f:fd:43:74:ab:8d:7d:d8:91:b6:e1:
                    52:f9:f6:53:aa:df:64
                ASN1 OID: secp384r1
                NIST CURVE: P-384
        Attributes:
            Requested Extensions:
                X509v3 Subject Alternative Name:
                    DNS:Apache2404.octox.demo, DNS:MYWEBSERVER.octox.demo
        Signature Algorithm: ecdsa-with-SHA256
        Signature Value:
```

###### RSA

*See jaotis on säilitatud neile, kes eelistavad RSA-põhiseid sertifikaate. Ülejäänud dokument kasutab ECC-d.*

Loo sertifikaadi päring ja privaatvõti käsuga

```bash
$ openssl req -newkey rsa:2048 -keyout Apache2021.key -sha256 -subj "/CN=Apache5.kaheksa.xi" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:Apache2021.kaheksa.xi,DNS:Apache5.kaheksa.xi")) -out Apache2021.csr -nodes
Generating a RSA private key
........+++++
.++++
writing new private key to 'Apache2021.key'
-----
```

1.  `Apache2021.key` on sertifikaadi privaatvõti;
2.  `Apache2021.csr` on sertifikaadi päringufail, mis edastatakse
    sertifitseerimiskeskusele;

3.  `Apache5.kaheksa.xi` on väljastatava sertifikaadi subjekt;
4.  `Apache2021.kaheksa.xi` ja `Apache5.kaheksa.xi` on sertifikaadil olevad
    SAN DNS nimed, mis peavad kindlasti vastama veebilehe tegelikule
    aadressile[^4]. Need nimed peavad ka nimeserveris lahenema.

Loodud sertifikaadi päringufaili sisu on võimalik vaadata käsuga

```bash
$ openssl req -in Apache2021.csr -noout -text
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: CN = Apache5.kaheksa.xi
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:c9:4f:a2:54:bd:1a:bb:88:a6:ec:16:c9:3e:28:
                    ee:f6:09:3d:a3:d7:86:fa:67:a4:e5:73:3b:38:70:
                    70:73:b0:01:95:7a:8d:c3:47:46:49:b9:12:52:20:
                    08:0c:ed:f5:ec:c5:4e:25:3e:27:9b:98:67:b0:bd:
                    c2:cd:00:98:54:36:d4:bf:b8:60:d9:aa:26:de:6a:
                    da:11:23:2e:a9:05:94:ff:e8:bb:d2:5e:c2:68:8d:
                    63:97:71:5e:0a:a0:49:fc:27:c7:28:c4:7d:53:12:
                    1c:e6:2e:9d:bd:81:5b:ff:6a:e5:cf:b5:1a:1b:a3:
                    5a:2e:9b:bd:0c:fe:c8:8f:ed:ff:b6:08:9a:1a:69:
                    4f:88:a1:1c:c7:9d:84:53:f0:77:2f:db:ba:2a:9a:
                    16:f4:78:02:ca:e2:29:f7:f0:f3:61:df:00:ce:3f:
                    fa:80:c5:ca:2d:37:a4:2e:a4:8c:be:a2:b3:c9:fd:
                    46:4e:20:fb:18:8b:3d:09:6a:be:01:3d:af:29:dd:
                    e2:b6:63:3c:3e:46:c1:7a:9b:08:83:c9:32:c5:54:
                    b2:e6:3d:a3:68:b6:8d:53:cb:36:c2:20:7d:77:63:
                    c7:cf:c9:11:36:b3:47:9b:10:8f:19:66:cb:a4:0f:
                    50:f5:35:bf:0d:53:82:cb:ad:3c:1f:5a:1a:2b:70:
                    a4:8f
                Exponent: 65537 (0x10001)
        Attributes:
            Requested Extensions:
                X509v3 Subject Alternative Name:
                    DNS:Apache2021.kaheksa.xi, DNS:Apache5.kaheksa.xi
        Signature Algorithm: sha256WithRSAEncryption
```

##### SSL sertifikaadi tellimine ja paigaldamine

Järgnevalt tuleb saata sertifikaadi päringufail `Apache2404.csr`
mõnele usaldusväärsele sertifitseerimiskeskusele. Näidiskonfiguratsiooni
tingimustes on sertifikaadi väljastajaks testkeskkonna
sertifitseerimiskeskus. Allkirjastatud sertifikaat väljastatakse PEM formaadis:

```
-----BEGIN CERTIFICATE-----
MIICGDCCAZGAwIBAgITEQAAAAnfuexBOWmmSg...
...
o6DunYynxvZsuwE5
-----END CERTIFICATE-----
```

Avades sertifikaadi Ubuntu failihalduris on näha järgmist:

![ECC sertifikaat Ubuntu failihalduris](./img/image2.png)

Sertifikaadis on kirjas ka algoritm ja alternatiivsed subjekti DNS
nimed:

![Sertifikaadi algoritm ja SAN DNS nimed](./img/image3.png)

Nagu näha, on sertifikaadi väljaandjaks sertifitseerimiskeskus nimega
`Punane`. Nüüd tuleb luua sertifikaadi fail, milles paiknevad nii
tulevane veebiserveri TLS sertifikaat kui ka selle väljaandjate ahel.
Selleks tuleb lisada veebiserveri sertifikaadifailile PEM formaadis
väljastaja sertifikaat ja salvestada faili nimega `Apache2404.pem`.

![Veebiserveri sertifikaadiahel Ubuntus](./img/image4.png)

Loodud fail tuleb paigaldada kausta `/etc/ssl/certs`. Lisaks peab
veebiserveri sertifikaadi privaatvõtme paigaldama kausta
`/etc/ssl/private`.

```bash
$ cp Apache2404.pem /etc/ssl/certs
$ cp Apache2404.key /etc/ssl/private
```

Nüüd on Apache2 serveripoolsed sertifikaadid olemas ja korrektselt
failisüsteemi paigaldatud.

#### Virtuaalse veebilehe loomine

Loo enda konfiguratsioonile eraldiseisev virtuaalne veebileht. Esmalt
tuleb luua kaust `/var/www/Apache2404`, kuhu paigaldada veebilehe
sisu.

```bash
$ mkdir /var/www/Apache2404
```

Paigalda loodud kausta mõni lihtne ja äratuntav veebileht. Siin näites
võtame testimiseks vaikimisi lehe kaustast `/var/www/html/index.html`.
Oma näites muudame pisut kopeeritud lehe päist ja sisu veendumaks, et
veebileht võetakse ikka õigest kohast.

Järgmiseks tee valmis virtuaalse veebilehe konfiguratsioonifail. Tee uus fail nimega `/etc/apache2/sites-available/Apache2404.conf` (nt käsuga `nano /etc/apache2/sites-available/Apache2404.conf`)

```bash
$ nano /etc/apache2/sites-available/Apache2404.conf
```

Nüüd muuda uut konfiguratsioonifaili vastavalt oma soovidele. Lisa sinna
järgmine sisu:

```apache
# <VirtualHost Apache2404.octox.demo:80>
#   Pöördudes http saidi poole juhitakse meid kahe järgmise rea abil automaatselt https saidile.
    ServerName Apache2404.octox.demo
    Redirect / https://Apache2404.octox.demo
# </VirtualHost>

<VirtualHost Apache2404.octox.demo:443>
    # Üldinfo
    ServerName Apache2404.octox.demo:443
    DocumentRoot /var/www/Apache2404

    # SSL häälestus
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/Apache2404.pem
    SSLCertificateKeyFile /etc/ssl/private/Apache2404.key

    # Vigade kogumise häälestus
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Aktiveeri loodud konfiguratsioon käsuga `a2ensite Apache2404.conf` ning taaskäivita Apache2 teenus.

```bash
$ a2ensite Apache2404.conf

Enabling site Apache2404.
To activate the new configuration, you need to run:
  systemctl reload apache2
$ systemctl reload apache2
```

Nüüd saab veebilehe poole pöördumiseks kasutada ühepoolset SSLi. Samuti
suunatakse automaatselt aadressilt
<http://Apache2404.octox.demo> aadressile
<https://Apache2404.octox.demo>.

#### Tulemus

![Apache veebiserver töötab ühepoolse SSLiga](./img/image5.png)

> **Märkus:** Sarnaseid virtuaalseid veebilehti erinevate nimede ja sama IP-aadressiga võib Apache2 veebiserverile luua mitmeid.

#### Kahepoolse sertifikaadinõude (SSLi) kehtestamine

Kui on soov võimaldada veebilehele ligipääs Eesti ID-kaardiga
autentides, tuleb olemasolevat konfiguratsiooni pisut täiendada.

Lisa `Apache2404.conf` failile järgmised read SSL sektsiooni:

```apache
SSLVerifyClient require
SSLVerifyDepth 2
SSLCACertificateFile /etc/ssl/certs/EID_Bundle.pem
```

Nüüd tuleb luua uus tekstifail [`EID_Bundle.pem`](#eid_bundle.pem), kuhu tuleb lisada
eID juur- ja kesktaseme sertifikaadid PEM formaadis
(`EE-GovCA2018`, `ESTEID2018`, `EEGovCA2025`, `ESTEID2025`). Selle faili abil
saab välja filtreerida kõik sertifitseerimiskeskused, mille alt
väljastatud sertifikaate uus loodud veebileht toetab. Kasutajale
näidatakse vaid neid sertifikaate, mis on väljastatud eelloetletud
ahelatest. Ubuntus avatuna näeb fail välja järgmine:

![Juur- ja kesktaseme sertifikaadid ühes failis](./img/image6.png)

Salvesta loodud fail nimega [`EID_Bundle.pem`](#eid_bundle.pem) ja kopeeri see kausta
`/etc/ssl/certs`. Veebiserveris muudatuse jõustumiseks taaskäivita
Apache2 käsuga `systemctl reload apache2`.

Pöördudes pärast muudatuse jõustumist uuesti veebilehe
<https://Apache2404.octox.demo> poole, küsitakse kasutaja sertifikaati.

![Kasutaja sertifikaadi valik](./img/image7.png)

Server pakub kasutajale välja sertifikaadid, mille väljastajad on
kirjeldatud failis [`EID_Bundle.pem`](#eid_bundle.pem). Pärast sertifikaadi kinnitamist
ja PIN-koodi sisestamist lubatakse kasutaja veebilehele - kahepoolne SSL
töötab.

Kõiki selles dokumendis kirjeldatud sätteid ühendav täielik näidiskonfiguratsiooni fail on saadaval [lisas](#apache2404_eid_demo.conf).

## Võimalikud lisakonfiguratsioonid

Käesoleva dokumendi eesmärk ei ole anda täpseid juhiseid optimaalseks
veebilehtede konfigureerimiseks ega turvamiseks, vaid tutvustada
konfiguratsiooni kahepoolse SSLi kasutamiseks Eesti ID-kaartidega.
Siiski on oluline arvestada allolevaga.

### Tulemüüri reegli loomine (vajadusel)

Tulemüüri reegli loomiseks tuleb terminalis käivitada käsk:

```bash
$ ufw allow 'SOOVITAV REEGEL'
```

Näiteks ainult HTTPS liikluse lubamiseks tuleb käivitada

```bash
$ ufw enable
Firewall is active and enabled on system startup
$ ufw allow 443/tcp
Rule added
Rule added (v6)
```

Kui tulemüüri staatus on aktiivne (`ufw enable`), siis päring `ufw status` näitab olemasolevaid reegleid.

```bash
$ ufw status
Status: active

To                         Action      From
--                         ------      ----
443/tcp                    ALLOW       Anywhere
443/tcp (v6)               ALLOW       Anywhere (v6)
```

### Kasutaja sertifikaadi staatuse kontroll OCSP teenuse vastu[^5]

OCSP (*Online Certificate Status Protocol*) teenuse abil saab kasutaja
sertifikaadi staatust kontrollida reaalajas. Iga kasutaja autentimisel
saadab veebiserver päringu OCSP teenusele, mis tagastab sertifikaadi
staatuse info.

SK ja Zetes pakuvad vaba ligipääsuga (tasuta) AIA OCSP teenust.
`ESTEID2018` ja `ESTEID2025` CA alt väljastatud sertifikaatide puhul on AIA
OCSP aadress juba sertifikaadis kirjas (<http://aia.sk.ee/esteid2018>,
<http://ocsp.eidpki.ee>).

![ESTEID2018 AIA OCSP aadress sertifikaadis](./img/image8.png)

Lubamaks kasutaja sertifikaadi staatuse kontrolli sertifikaadis määratud
AIA OCSP teenuse abil, tuleb Apache2 SSL konfiguratsiooni lisada
järgmised read:

```apache
SSLOCSPEnable leaf
SSLOCSPUseRequestNonce off
```

Taaskäivita Apache2 veebiteenus käsuga `systemctl reload apache2`.
Ülaltoodud konfiguratsiooni puhul võetakse OCSP teenuse aadress kasutaja
sertifikaadist.

### Vaikimisi veebilehe eemaldamine 

Apache2 paigaldusega paigaldatakse ka vaikimisi veebileht. Selle
eemaldamiseks lahendusest tuleb käivitada `a2dissite 000-default.conf` ja aktiveerida muudatus käsuga `systemctl reload apache2`.

```bash
$ a2dissite 000-default.conf
Site 000-default disabled.
To activate the new configuration, you need to run:
  systemctl reload apache2
$ systemctl reload apache2
```

### Soovituslikud Apache turvasätted

#### SSL/TLS

Apache versioonil 2.4.55 on vaikimisi lubatud kõik SSL/TLS protokollid,
mis on uuemad kui SSL3:

```bash
$ grep -i -r "SSLProtocol" /etc/apache2/mods-available/
/etc/apache2/mods-available/ssl.conf:SSLProtocol all -SSLv3
```

Tänapäeval on tungivalt soovitav mitte kasutada TLS protokolli
versioonist 1.2 madalamaid versioone. Juba mõnda aega on kasutusel ka
TLS versioon 1.3.

Kui puudub spetsiifiline nõue TLS 1.2 versiooni lubamiseks, siis on
soovitav kasutada vaid TLS versiooni 1.3. TLS 1.2 on küll korrektse
konfiguratsiooni puhul väga stabiilne ja turvaline, ent TLS 1.3 on
kiirem, vaikimisi turvalisem ja nõuab vähem konfigureerimist.
Standardlahendustes võiks TLS 1.2 olla toetatud vaid tõestatud vajaduse
puhul ja sel juhul tuleb olla veendunud, et kasutusel on vaid turvalised
šifrikomplektid ja laiendused.

Kui on soov Apache serveris kasutada vaid protokoll TLS 1.3, tuleb
konfiguratsioonifaili lisada rida

```apache
SSLProtocol -all +TLSv1.3
```

Toetamaks TLS versioone 1.2 ja 1.3, tuleb konfiguratsioonireale lisada
`+TLSv1.2`

Alternatiivina saab sama muudatuse teha serveripõhiselt konfigureerides
parameetrit `SSLProtocol` failis `/etc/apache2/mods-available/ssl.conf`.

Rohkem infot TLS protokolli kasutamise soovituste kohta leiab RIA
tellitud krüptograafiliste algoritmide elutsükli uuringust aadressil
<https://www.id.ee/artikkel/kruptograafiliste-algoritmide-elutsukli-uuringud-2/>.

##### Šifrikomplektid (*Cipher suites*)

TLS 1.3 versiooni kõiki šifreid peetakse hetkeseisuga turvaliseks, seega
turvakaalutlustel selle protokolli jaoks lisakonfiguratsiooni looma ei
pea.

TLS 1.2 puhul see päris nii ei ole. Apache 2.4.55 versiooniga on
vaikimisi kasutusel suur hulk erinevaid TLS šifreid[^6], mida näeb
käsuga

```bash
$ openssl ciphers -v
```

Vaikimisi on šifrite kasutamise osas defineeritud ainult kaks reeglit:

1.  HIGH -- lubatud on mõned šifrid võtme pikkusega 128 bitti ja kõik
    tugevamad;
2.  !aNULL -- keelatud on šifrite komplektid, mis ei toeta autentimist.

```apache
SSLCipherSuite HIGH:!aNULL
```

Kui on soov määrata täpsemalt TLS 1.2 protokolliga kasutatavaid
šifrikomplekte, saab Apache kaustapõhises konfiguratsioonifailis
kasutada direktiivi `SSLCipherSuite`. Siin omakorda saab kasutada kas
eeldefineeritud muutujaid või täpseid šifrikomplektide kirjeldusi.

Kindlat soovitust erinevate šifrikomplektide kasutamiseks ei ole
võimalik ilma veebilehele esitatavaid tingimusi teadmata anda. Küll aga
tuleb kindlasti eemaldada loendist ebaturvalised šifrikomplektid.
Mõistlik on kirjeldada konkreetsed lubatud šifrikomplektid TLS 1.2
kasutamiseks.

Näide:

- Kasutades konfiguratsioonifailis järgmist käsurida, lubatakse vaid kirjeldatud šifrikomplektide kasutamine:

  ```apache
  SSLCipherSuite "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384"
  ```

Alternatiivina saab kasutatavaid šifreid konfigureerida serveripõhiselt
failis `/etc/apache2/mods-available/ssl.conf` muutes selles parameetrit
`SSLCipherSuite`.

Rohkem infot šifrikomplektide soovituste kohta leiab RIA tellitud
krüptograafiliste algoritmide elutsükli uuringust aadressil
<https://www.id.ee/artikkel/kruptograafiliste-algoritmide-elutsukli-uuringud-2/>.

##### SSLHonorCipherOrder

Oluline šifritega seotud parameeter on ka `SSLHonorCipherOrder`, mille
väärtus on soovitav konfiguratsioonifailis määrata `ON` asendisse. Sel
juhul eelistatakse serveri šifrikomplektide valikut kasutaja omale.
Vaikimisi on see parameeter määramata ja vaikimisi väärtuseks on
määratud `off`.

#### Kasutajasertifikaatide lisafiltreerimine

Oluline! Kindlustamaks, et veebiteenuse poole saavad pöörduda vaid
korrektsete sertifikaatidega kasutajad, tuleb serveri konfiguratsioonis
kehtestada järgmised nõuded:

1.  sertifikaadis peab olema korrektne väli `extendedKeyUsage`;
2.  sertifikaadi väljastaja peab olema `ESTEID2018` või `ESTEID2025`.

Selleks tuleb lisada Apache konfiguratsiooni read:

```apache
<Location "/">
Require expr (
  (%{SSL_CLIENT_I_DN_CN} == "ESTEID2018" || %{SSL_CLIENT_I_DN_CN} == "ESTEID2025")
  and "TLS Web Client Authentication, E-mail Protection" in PeerExtList('extendedKeyUsage')
)
</Location>
```

Selle konfiguratsiooni võib lisada kas virtuaalse hosti või Apache
serveri üld-konfiguratsiooni juurde. Pärast ülaltoodud tingimuste
lisamist on teenuse poole lubatud pöörduda vaid sertifikaatidega millel
on korrektne `extendedKeyUsage` väli ning mis on väljastatud serveri
poolt lubatud ahelast.

> **Märkus:** Kui on kasutusel mõni muu liikluse filtreerimise vahend/võimalus, siis
> on soovitav turvaline konfiguratsioon juurutada ka seal. SK on F5
> konfiguratsiooni osas publitseerinud järgmise informatsiooni (vt.
> peakükki „Only accept certificates with trusted key usage"):
> <https://github.com/SK-EID/smart-id-documentation/wiki/Secure-Implementation-Guide>

> **Märkus:** SK soovitused turvaliseks autentimiseks ID-kaardiga on leitavad
> peatükist „Defence: implement ID-card authentication securely":
> <https://github.com/SK-EID/smart-id-documentation/wiki/Secure-Implementation-Guide>

> **Märkus:** Soovituslik meetod ebakorrektsete sertifikaatide vältimiseks on
> kasutada sertifikaatides olevaid OIDe. Paraku ei ole hetkeseisuga
> teada meetodit, kuidas seda serveri tasemel teha. Võimalusel tuleks
> võtta autentimise sertifikaat veebirakenduse tasemel lahti ja
> kontrollida, kas see sisaldab mõnda korrektset OIDi ning kui ei
> sisalda, siis mitte autentida. Hetkeseisuga teadaolevad OIDid on SK
> publitseerinud peatükis „Only accept certificates with trusted
> issuance policy":
> <https://github.com/SK-EID/smart-id-documentation/wiki/Secure-Implementation-Guide>

#### Kasutajale kuvatavate sertifikaatide filtreerimine

Vaikimisi konfiguratsioonis ei piirata kasutajale kuvatavate
sertifikaatide valikut, mis tähendab, et veebiserverisse autentimisel
näidatakse kasutajale kõiki kasutaja käsutuses olevaid autentimise
sertifikaate. Korrektne on kasutajale näidata aga vaid neid
sertifikaate, mis on väljastatud ahelatest `ESTEID2018` või `ESTEID2025`.
Selleks tuleb:

1.  luua aktsepteeritud ahelate fail
    [`/etc/ssl/certs/DN_Bundle.pem`](#dn_bundle.pem)
2.  panna sinna `ESTEID2018` ja `ESTEID2025` sertifikaadid PEM formaadis

3.  lisada Apache SSL häälestuse sektsiooni direktiiv `SSLCADNRequestFile /etc/ssl/certs/DN_Bundle.pem`
    ja uus konfiguratsioon salvestada
4.  taaskäivitada Apache server käsuga `systemctl reload apache2`

Nüüd saadab Apache server kasutajale info, et toetatud on ainult
`ESTEID2018` ja `ESTEID2025` ahelatest väljastatud sertifikaadid ning
kasutajale kuvataksegi ainult nende ahelatest väljastatud sertifikaate.

##### HTTP Strict Transport Security (HSTS) lubamine

1.  Luba terminalis *mod-headers* käsuga `a2enmod headers`

    ```bash
    $ a2enmod headers
    Enabling module headers.
    To activate the new configuration, you need to run:
      systemctl restart apache2
    ```

2.  Lisa Apache konfiguratsioonifaili rida:

    ```apache
    # Enable HSTS.
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    ```

3.  Taaskäivita Apache teenus mõlema muudatuse jõustamiseks:

    ```bash
    $ systemctl restart apache2
    ```

##### Muud võimalused

Lisaks TLS ja šifrikomplektide häälestusele on soovitav pöörata
tähelepanu Apache serveri turvalisusele ka järgmiste punktide vaates:

- Hoida operatsioonisüsteem uuendatuna.
- Hoida Apache uuendatuna.
- Käidelda Apachet tavakasutaja õigustes.
- Keelata serveri info presenteerimine.
- Eemaldada ebaolulised moodulid.
- Lisada ja konfigureerida *Mod Security*.
- Lisada ja konfigureerida *Mod Evasive*.
- Keelata *listing* ligipääs vaikimisi kataloogile.
- Lubada logimine.
- ...

Ülaltoodu on näidisloend võimalustest Apache turvalisemaks muutmiseks.
Põhjalikumaid soovitusi on võimalik leida internetist:
<https://www.google.com/search?q=how+to+secure+apache+server>.

## Lisa

### EID_Bundle.pem

```
# EE-GovCA2018
-----BEGIN CERTIFICATE-----
MIIE+DCCBFmgAwIBAgIQMLOwlXoR0oFbj52nmRsnezAKBggqhkjOPQQDBDBaMQsw
CQYDVQQGEwJFRTEbMBkGA1UECgwSU0sgSUQgU29sdXRpb25zIEFTMRcwFQYDVQRh
DA5OVFJFRS0xMDc0NzAxMzEVMBMGA1UEAwwMRUUtR292Q0EyMDE4MB4XDTE4MDkw
NTA5MTEwM1oXDTMzMDkwNTA5MTEwM1owWjELMAkGA1UEBhMCRUUxGzAZBgNVBAoM
ElNLIElEIFNvbHV0aW9ucyBBUzEXMBUGA1UEYQwOTlRSRUUtMTA3NDcwMTMxFTAT
BgNVBAMMDEVFLUdvdkNBMjAxODCBmzAQBgcqhkjOPQIBBgUrgQQAIwOBhgAEAMcb
/dmAcVo/b2azEPS6CfW7fEA2KuHKC53D7ShVNvLz4QUjCdTXjds/4u99jUoYEQec
luVVzMlgEJR1nkN2eOrLAZYxPjwG5HiI1iZEyW9QKVdeEgyvhzWWTNHGjV3HdZRv
7L9o4533PtJAyqJq9OTs6mjsqwFXjH49bfZ6CGmzUJsHo4ICvDCCArgwEgYDVR0T
AQH/BAgwBgEB/wIBATAOBgNVHQ8BAf8EBAMCAQYwNAYDVR0lAQH/BCowKAYIKwYB
BQUHAwkGCCsGAQUFBwMCBggrBgEFBQcDBAYIKwYBBQUHAwEwHQYDVR0OBBYEFH4p
Vuc0knhOd+FvLjMqmHHB/TSfMB8GA1UdIwQYMBaAFH4pVuc0knhOd+FvLjMqmHHB
/TSfMIICAAYDVR0gBIIB9zCCAfMwCAYGBACPegECMAkGBwQAi+xAAQIwMgYLKwYB
BAGDkSEBAQEwIzAhBggrBgEFBQcCARYVaHR0cHM6Ly93d3cuc2suZWUvQ1BTMA0G
CysGAQQBg5EhAQECMA0GCysGAQQBg5F/AQEBMA0GCysGAQQBg5EhAQEFMA0GCysG
AQQBg5EhAQEGMA0GCysGAQQBg5EhAQEHMA0GCysGAQQBg5EhAQEDMA0GCysGAQQB
g5EhAQEEMA0GCysGAQQBg5EhAQEIMA0GCysGAQQBg5EhAQEJMA0GCysGAQQBg5Eh
AQEKMA0GCysGAQQBg5EhAQELMA0GCysGAQQBg5EhAQEMMA0GCysGAQQBg5EhAQEN
MA0GCysGAQQBg5EhAQEOMA0GCysGAQQBg5EhAQEPMA0GCysGAQQBg5EhAQEQMA0G
CysGAQQBg5EhAQERMA0GCysGAQQBg5EhAQESMA0GCysGAQQBg5EhAQETMA0GCysG
AQQBg5EhAQEUMA0GCysGAQQBg5F/AQECMA0GCysGAQQBg5F/AQEDMA0GCysGAQQB
g5F/AQEEMA0GCysGAQQBg5F/AQEFMA0GCysGAQQBg5F/AQEGMDEGCisGAQQBg5Eh
CgEwIzAhBggrBgEFBQcCARYVaHR0cHM6Ly93d3cuc2suZWUvQ1BTMBgGCCsGAQUF
BwEDBAwwCjAIBgYEAI5GAQEwCgYIKoZIzj0EAwQDgYwAMIGIAkIBk698EqetY9Tt
6HwO50CfzdIIjKmlfCI34xKdU7J+wz1tNVu2tHJwEhdsH0e92i969sRDp1RNPlVh
4XFJzI3oQFQCQgGVxmcuVnsy7NUscDZ0erwovmbFOsNxELCANxNSWx5xMqzEIhV8
46opxu10UFDIBBPzkbBenL4h+g/WU7lG78fIhA==
-----END CERTIFICATE-----
# ESTEID2018
-----BEGIN CERTIFICATE-----
MIIFVzCCBLigAwIBAgIQdUf6rBR0S4tbo2bU/mZV7TAKBggqhkjOPQQDBDBaMQsw
CQYDVQQGEwJFRTEbMBkGA1UECgwSU0sgSUQgU29sdXRpb25zIEFTMRcwFQYDVQRh
DA5OVFJFRS0xMDc0NzAxMzEVMBMGA1UEAwwMRUUtR292Q0EyMDE4MB4XDTE4MDky
MDA5MjIyOFoXDTMzMDkwNTA5MTEwM1owWDELMAkGA1UEBhMCRUUxGzAZBgNVBAoM
ElNLIElEIFNvbHV0aW9ucyBBUzEXMBUGA1UEYQwOTlRSRUUtMTA3NDcwMTMxEzAR
BgNVBAMMCkVTVEVJRDIwMTgwgZswEAYHKoZIzj0CAQYFK4EEACMDgYYABAHHOBlv
7UrRPYP1yHhOb7RA/YBDbtgynSVMqYdxnFrKHUXh6tFkghvHuA1k2DSom1hE5kqh
B5VspDembwWDJBOQWQGOI/0t3EtccLYjeM7F9xOPdzUbZaIbpNRHpQgVBpFX0xpL
TgW27MpIMhU8DHBWFpeAaNX3eUpD4gC5cvhsK0RFEqOCAx0wggMZMB8GA1UdIwQY
MBaAFH4pVuc0knhOd+FvLjMqmHHB/TSfMB0GA1UdDgQWBBTZrHDbX36+lPig5L5H
otA0rZoqEjAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADCCAc0G
A1UdIASCAcQwggHAMAgGBgQAj3oBAjAJBgcEAIvsQAECMDIGCysGAQQBg5EhAQEB
MCMwIQYIKwYBBQUHAgEWFWh0dHBzOi8vd3d3LnNrLmVlL0NQUzANBgsrBgEEAYOR
IQEBAjANBgsrBgEEAYORfwEBATANBgsrBgEEAYORIQEBBTANBgsrBgEEAYORIQEB
BjANBgsrBgEEAYORIQEBBzANBgsrBgEEAYORIQEBAzANBgsrBgEEAYORIQEBBDAN
BgsrBgEEAYORIQEBCDANBgsrBgEEAYORIQEBCTANBgsrBgEEAYORIQEBCjANBgsr
BgEEAYORIQEBCzANBgsrBgEEAYORIQEBDDANBgsrBgEEAYORIQEBDTANBgsrBgEE
AYORIQEBDjANBgsrBgEEAYORIQEBDzANBgsrBgEEAYORIQEBEDANBgsrBgEEAYOR
IQEBETANBgsrBgEEAYORIQEBEjANBgsrBgEEAYORIQEBEzANBgsrBgEEAYORIQEB
FDANBgsrBgEEAYORfwEBAjANBgsrBgEEAYORfwEBAzANBgsrBgEEAYORfwEBBDAN
BgsrBgEEAYORfwEBBTANBgsrBgEEAYORfwEBBjAqBgNVHSUBAf8EIDAeBggrBgEF
BQcDCQYIKwYBBQUHAwIGCCsGAQUFBwMEMGoGCCsGAQUFBwEBBF4wXDApBggrBgEF
BQcwAYYdaHR0cDovL2FpYS5zay5lZS9lZS1nb3ZjYTIwMTgwLwYIKwYBBQUHMAKG
I2h0dHA6Ly9jLnNrLmVlL0VFLUdvdkNBMjAxOC5kZXIuY3J0MBgGCCsGAQUFBwED
BAwwCjAIBgYEAI5GAQEwMAYDVR0fBCkwJzAloCOgIYYfaHR0cDovL2Muc2suZWUv
RUUtR292Q0EyMDE4LmNybDAKBggqhkjOPQQDBAOBjAAwgYgCQgDeuUY4HczUbFKS
002HZ88gclgYdztHqglENyTMtXE6dMBRnCbgUmhBCAA0mJSHbyFJ8W9ikLiSyurm
kJM0hDE9KgJCASOqA405Ia5nKjTJPNsHQlMi7KZsIcTHOoBccx+54N8ZX1MgBozJ
mT59rZY/2/OeE163BAwD0UdUQAnMPP6+W3Vd
-----END CERTIFICATE-----
# EEGovCA2025
-----BEGIN CERTIFICATE-----
MIICljCCAhygAwIBAgIUKbkXJo8FWjthNs7Hgduq1RiXqwswCgYIKoZIzj0EAwMw
WDEUMBIGA1UEAwwLRUVHb3ZDQTIwMjUxFzAVBgNVBGEMDk5UUkVFLTE3MDY2MDQ5
MRowGAYDVQQKDBFaZXRlcyBFc3RvbmlhIE/DnDELMAkGA1UEBhMCRUUwHhcNMjUw
NTA2MDgxODEzWhcNNDAwNTA1MDgxODEyWjBYMRQwEgYDVQQDDAtFRUdvdkNBMjAy
NTEXMBUGA1UEYQwOTlRSRUUtMTcwNjYwNDkxGjAYBgNVBAoMEVpldGVzIEVzdG9u
aWEgT8OcMQswCQYDVQQGEwJFRTB2MBAGByqGSM49AgEGBSuBBAAiA2IABH0zMU4D
UN/Ay6gUdWzMUDAYFaau0flpuuicO2bfK7kHNGw+psRRn6DaF/4cVQd8qHxbDF2x
N4jJf1bSpQHLsc2RZHSCI8qb4E9GmB5MDoVVxiXnBHOOW3+55Qm/BfwcwaOBpjCB
ozASBgNVHRMBAf8ECDAGAQH/AgEBMB8GA1UdIwQYMBaAFKqAqJsPu0umfsUC9HLN
LPGlKdm3MD0GA1UdIAQ2MDQwMgYEVR0gADAqMCgGCCsGAQUFBwIBFhxodHRwczov
L3JlcG9zaXRvcnkuZWlkcGtpLmVlMB0GA1UdDgQWBBSqgKibD7tLpn7FAvRyzSzx
pSnZtzAOBgNVHQ8BAf8EBAMCAQYwCgYIKoZIzj0EAwMDaAAwZQIwOy8+eV+yYNXt
XcEEdOuQd60O7lXucK3W4cDewxEoEXb4iTYFswWUZq3DacfmeE+/AjEAkzHeNdru
QqKfvqTFB3eNRnMycNcnJ3rmGe37u9zgH8wnQUuMhUClOGxeRcK4NV9I
-----END CERTIFICATE-----
# ESTEID2025
-----BEGIN CERTIFICATE-----
MIIDDzCCApagAwIBAgIUUFQrcGtK7/jCP+GyAOTPvbglGlcwCgYIKoZIzj0EAwMw
WDEUMBIGA1UEAwwLRUVHb3ZDQTIwMjUxFzAVBgNVBGEMDk5UUkVFLTE3MDY2MDQ5
MRowGAYDVQQKDBFaZXRlcyBFc3RvbmlhIE/DnDELMAkGA1UEBhMCRUUwHhcNMjUw
NTA3MTMyMDA3WhcNNDAwNTAzMTMyMDA2WjBXMRMwEQYDVQQDDApFU1RFSUQyMDI1
MRcwFQYDVQRhDA5OVFJFRS0xNzA2NjA0OTEaMBgGA1UECgwRWmV0ZXMgRXN0b25p
YSBPw5wxCzAJBgNVBAYTAkVFMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEdSEmb1An
xN7G22CCEQ3ts2YZNieTUZP4Vc4iObhmL/um4EXkiA4HgyCiR5T6olKAEkPdxFBs
fmcLoPN+TmBO8ZpLGEqy1Vwf59ahDW7dQiLXTIAEiGCoXSWI9MvtHDZ2o4IBIDCC
ARwwEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBSqgKibD7tLpn7FAvRy
zSzxpSnZtzBABggrBgEFBQcBAQQ0MDIwMAYIKwYBBQUHMAKGJGh0dHA6Ly9jcnQu
ZWlkcGtpLmVlL0VFR292Q0EyMDI1LmNydDA9BgNVHSAENjA0MDIGBFUdIAAwKjAo
BggrBgEFBQcCARYcaHR0cHM6Ly9yZXBvc2l0b3J5LmVpZHBraS5lZTA1BgNVHR8E
LjAsMCqgKKAmhiRodHRwOi8vY3JsLmVpZHBraS5lZS9FRUdvdkNBMjAyNS5jcmww
HQYDVR0OBBYEFJLAOLC4NhJo9crtZu5HKohtpo3oMA4GA1UdDwEB/wQEAwIBBjAK
BggqhkjOPQQDAwNnADBkAjANipgLQqdM985dSFZfKvU9A7Sz2YdmmUSZBxu0lL7Q
XKzqa0ZDyXmf03NPLNAC6dICMBQiROZbLoPezO9LDl847UbENx85hloLlzweWjqP
rY++Xj8FjCD1C9hnblsVgj3XAA==
-----END CERTIFICATE-----
```

### DN_Bundle.pem

```
# ESTEID2018
-----BEGIN CERTIFICATE-----
MIIFVzCCBLigAwIBAgIQdUf6rBR0S4tbo2bU/mZV7TAKBggqhkjOPQQDBDBaMQsw
CQYDVQQGEwJFRTEbMBkGA1UECgwSU0sgSUQgU29sdXRpb25zIEFTMRcwFQYDVQRh
DA5OVFJFRS0xMDc0NzAxMzEVMBMGA1UEAwwMRUUtR292Q0EyMDE4MB4XDTE4MDky
MDA5MjIyOFoXDTMzMDkwNTA5MTEwM1owWDELMAkGA1UEBhMCRUUxGzAZBgNVBAoM
ElNLIElEIFNvbHV0aW9ucyBBUzEXMBUGA1UEYQwOTlRSRUUtMTA3NDcwMTMxEzAR
BgNVBAMMCkVTVEVJRDIwMTgwgZswEAYHKoZIzj0CAQYFK4EEACMDgYYABAHHOBlv
7UrRPYP1yHhOb7RA/YBDbtgynSVMqYdxnFrKHUXh6tFkghvHuA1k2DSom1hE5kqh
B5VspDembwWDJBOQWQGOI/0t3EtccLYjeM7F9xOPdzUbZaIbpNRHpQgVBpFX0xpL
TgW27MpIMhU8DHBWFpeAaNX3eUpD4gC5cvhsK0RFEqOCAx0wggMZMB8GA1UdIwQY
MBaAFH4pVuc0knhOd+FvLjMqmHHB/TSfMB0GA1UdDgQWBBTZrHDbX36+lPig5L5H
otA0rZoqEjAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADCCAc0G
A1UdIASCAcQwggHAMAgGBgQAj3oBAjAJBgcEAIvsQAECMDIGCysGAQQBg5EhAQEB
MCMwIQYIKwYBBQUHAgEWFWh0dHBzOi8vd3d3LnNrLmVlL0NQUzANBgsrBgEEAYOR
IQEBAjANBgsrBgEEAYORfwEBATANBgsrBgEEAYORIQEBBTANBgsrBgEEAYORIQEB
BjANBgsrBgEEAYORIQEBBzANBgsrBgEEAYORIQEBAzANBgsrBgEEAYORIQEBBDAN
BgsrBgEEAYORIQEBCDANBgsrBgEEAYORIQEBCTANBgsrBgEEAYORIQEBCjANBgsr
BgEEAYORIQEBCzANBgsrBgEEAYORIQEBDDANBgsrBgEEAYORIQEBDTANBgsrBgEE
AYORIQEBDjANBgsrBgEEAYORIQEBDzANBgsrBgEEAYORIQEBEDANBgsrBgEEAYOR
IQEBETANBgsrBgEEAYORIQEBEjANBgsrBgEEAYORIQEBEzANBgsrBgEEAYORIQEB
FDANBgsrBgEEAYORfwEBAjANBgsrBgEEAYORfwEBAzANBgsrBgEEAYORfwEBBDAN
BgsrBgEEAYORfwEBBTANBgsrBgEEAYORfwEBBjAqBgNVHSUBAf8EIDAeBggrBgEF
BQcDCQYIKwYBBQUHAwIGCCsGAQUFBwMEMGoGCCsGAQUFBwEBBF4wXDApBggrBgEF
BQcwAYYdaHR0cDovL2FpYS5zay5lZS9lZS1nb3ZjYTIwMTgwLwYIKwYBBQUHMAKG
I2h0dHA6Ly9jLnNrLmVlL0VFLUdvdkNBMjAxOC5kZXIuY3J0MBgGCCsGAQUFBwED
BAwwCjAIBgYEAI5GAQEwMAYDVR0fBCkwJzAloCOgIYYfaHR0cDovL2Muc2suZWUv
RUUtR292Q0EyMDE4LmNybDAKBggqhkjOPQQDBAOBjAAwgYgCQgDeuUY4HczUbFKS
002HZ88gclgYdztHqglENyTMtXE6dMBRnCbgUmhBCAA0mJSHbyFJ8W9ikLiSyurm
kJM0hDE9KgJCASOqA405Ia5nKjTJPNsHQlMi7KZsIcTHOoBccx+54N8ZX1MgBozJ
mT59rZY/2/OeE163BAwD0UdUQAnMPP6+W3Vd
-----END CERTIFICATE-----
# ESTEID2025
-----BEGIN CERTIFICATE-----
MIIDDzCCApagAwIBAgIUUFQrcGtK7/jCP+GyAOTPvbglGlcwCgYIKoZIzj0EAwMw
WDEUMBIGA1UEAwwLRUVHb3ZDQTIwMjUxFzAVBgNVBGEMDk5UUkVFLTE3MDY2MDQ5
MRowGAYDVQQKDBFaZXRlcyBFc3RvbmlhIE/DnDELMAkGA1UEBhMCRUUwHhcNMjUw
NTA3MTMyMDA3WhcNNDAwNTAzMTMyMDA2WjBXMRMwEQYDVQQDDApFU1RFSUQyMDI1
MRcwFQYDVQRhDA5OVFJFRS0xNzA2NjA0OTEaMBgGA1UECgwRWmV0ZXMgRXN0b25p
YSBPw5wxCzAJBgNVBAYTAkVFMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEdSEmb1An
xN7G22CCEQ3ts2YZNieTUZP4Vc4iObhmL/um4EXkiA4HgyCiR5T6olKAEkPdxFBs
fmcLoPN+TmBO8ZpLGEqy1Vwf59ahDW7dQiLXTIAEiGCoXSWI9MvtHDZ2o4IBIDCC
ARwwEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBSqgKibD7tLpn7FAvRy
zSzxpSnZtzBABggrBgEFBQcBAQQ0MDIwMAYIKwYBBQUHMAKGJGh0dHA6Ly9jcnQu
ZWlkcGtpLmVlL0VFR292Q0EyMDI1LmNydDA9BgNVHSAENjA0MDIGBFUdIAAwKjAo
BggrBgEFBQcCARYcaHR0cHM6Ly9yZXBvc2l0b3J5LmVpZHBraS5lZTA1BgNVHR8E
LjAsMCqgKKAmhiRodHRwOi8vY3JsLmVpZHBraS5lZS9FRUdvdkNBMjAyNS5jcmww
HQYDVR0OBBYEFJLAOLC4NhJo9crtZu5HKohtpo3oMA4GA1UdDwEB/wQEAwIBBjAK
BggqhkjOPQQDAwNnADBkAjANipgLQqdM985dSFZfKvU9A7Sz2YdmmUSZBxu0lL7Q
XKzqa0ZDyXmf03NPLNAC6dICMBQiROZbLoPezO9LDl847UbENx85hloLlzweWjqP
rY++Xj8FjCD1C9hnblsVgj3XAA==
-----END CERTIFICATE-----
```

### Apache2404_EID_Demo.conf

Täielik näidiskonfiguratsiooni fail on saadaval aadressil <https://installer.id.ee/media/id2019/Apache_2.4.63_EID_Demo.conf>.

```apache
<VirtualHost Apache2404.octox.demo:80>
    ServerName Apache2404.octox.demo
    Redirect / https://Apache2404.octox.demo
</VirtualHost>

<VirtualHost Apache2404.octox.demo:443>
    # Üldinfo
    ServerName Apache2404.octox.demo:443
    DocumentRoot /var/www/Apache2404

    # SSL häälestus
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/Apache2404.pem
    SSLCertificateKeyFile /etc/ssl/private/Apache2404.key

    # Kasutajasertifikaadi autentimine
    SSLVerifyClient require
    SSLVerifyDepth 2
    SSLCACertificateFile /etc/ssl/certs/EID_Bundle.pem

    # AIA-OCSP
    SSLOCSPEnable leaf
    SSLOCSPUseRequestNonce off

    # TLS häälestus — kasutada ainult TLS 1.3
    SSLProtocol -all +TLSv1.3
    # TLS 1.2 toetamiseks lisada: SSLProtocol -all +TLSv1.2 +TLSv1.3
    # SSLCipherSuite "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384"
    SSLHonorCipherOrder ON

    # Kasutajale kuvatavate sertifikaatide filtreerimine
    SSLCADNRequestFile /etc/ssl/certs/DN_Bundle.pem

    # Kasutajasertifikaatide lisafiltreerimine
    <Location "/">
    Require expr (
      (%{SSL_CLIENT_I_DN_CN} == "ESTEID2018" || %{SSL_CLIENT_I_DN_CN} == "ESTEID2025")
      and "TLS Web Client Authentication, E-mail Protection" in PeerExtList('extendedKeyUsage')
    )
    </Location>

    # HSTS
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"

    # Logimine
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

[^1]: Hetkeseisuga (22.04.2026) on Ubuntuga vaikimisi kaasas versioon
    2.4.58, viimane Apache versioon on 2.4.66.

[^2]: Lisaks käsureal kirjeldatud sertifikaadi atribuutidele C, O ja CN
    on võimalik soovi korral lisaks kirjeldada atribuudid L, OU ja S.
    Võib kasutada ka ainult CNi.

[^3]: Kaasaegsed veebilehitsejad ei pea veebilehte usaldusväärseks, kui
    vähemalt üks SAN DNS ei vasta veebilehe tegelikule aadressile.

[^4]: Kaasaegsed veebilehitsejad ei pea veebilehte usaldusväärseks, kui
    vähemalt üks SAN DNS ei vasta veebilehe tegelikule aadressile.

[^5]: Sertifikaatide kehtivust on võimalik kontrollida ka sertifikaatide
    tühistusnimekirjade (CRL) abil, ent sellel käesolevas dokumendis ei
    peatuta, kuna OCSP-põhine lahendus on eelistatum.

[^6]: Siin ei käsitleta teiste TLS protokollide šifreid, kuna
    versioonist 1.2 vanemad protokollid on eelduslikult keelatud ja 1.3
    versioon on hetkel eelistatuim.
