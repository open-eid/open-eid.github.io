# Ubuntu Apache2 veebiserveri kahepoolse SSLi häälestus Eesti ID‑kaartide vaates

**[In English](index.md)**

**Versioon:** 26.08/1

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
| 21.08.2026 | 26.08/1  | Uuendatud sertifikaadivõtme, TLS-protokollide, šifrikomplektide, sertifikaadipoliitikate ja OCSP juhiseid 2026. aasta krüptograafiliste algoritmide elutsükli aruande põhjal. — Muutja: Raul Metsma

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

Genereeri igale sõltumatule TLS-serverile eraldi privaatvõti. Ära kopeeri
sama võtit mitmesse serverisse üksnes seetõttu, et metamärgiga või mitme SAN
nimega sertifikaat kataks kõik serverinimed. Eraldi võtmed piiravad serveri
või võtme kompromiteerumise mõju.

Tootmislahenduses kasuta võimaluse korral füüsilist turvamoodulit (HSM) või
samaväärset mitteeksporditava võtmega riistvaralist võtmehoidlat. Genereeri
võti seadmes ja hoia see mitteeksporditavana. Enne kasutuselevõttu veendu, et
HSM, OpenSSL-i integratsioon ja sertifikaadi väljastaja toetavad valitud ECDSA
P-384 võtit. Näite failipõhine võti ei ole HSM-i seadistus.

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

### Kliendisertifikaadi tühistusoleku kontroll OCSP abil[^4]

OCSP (*Online Certificate Status Protocol*) võimaldab Apache'il kontrollida
kliendisertifikaadi tühistusolekut autentimise ajal.

CA-de `ESTEID2018` ja `ESTEID2025` väljastatud sertifikaatides on AIA OCSP
teenuse aadress (<http://aia.sk.ee/esteid2018> ja
<http://ocsp.eidpki.ee>).

![ESTEID2018 AIA OCSP aadress sertifikaadis](./img/image8.png)

Lubamaks kasutaja sertifikaadi staatuse kontrolli sertifikaadis määratud
AIA OCSP teenuse abil, tuleb Apache2 SSL konfiguratsiooni lisada
järgmised read:

```apache
SSLOCSPEnable leaf
SSLOCSPUseRequestNonce off
```

Väärtus `leaf` kontrollib lõppkasutaja sertifikaati. OCSP teenuse aadress
võetakse sellest sertifikaadist. See range konfiguratsioon ei kasuta valikut
`no_ocsp_for_cert_ok`: puuduva OCSP aadressi või ebaõnnestunud kontrolli korral
kliendisertifikaadiga autentimine ei õnnestu. Luba serverist väljuv
HTTP-liiklus mõlemasse OCSP teenusesse ja monitoori Apache tõrkeid. Pärast
muudatuse rakendamist laadi Apache uuesti käsuga `systemctl reload apache2`.

### Serverisertifikaadi OCSP vastuse stapling

Eespool kirjeldatud kliendisertifikaadi kontroll ja serverisertifikaadi OCSP
stapling on eri funktsioonid. Stapling võimaldab Apache'il hankida oma
serverisertifikaadi kohta allkirjastatud olekuvastuse ja saata selle TLS
kätluse ajal. Nii ei pea iga veebilehitseja väljastanud CA-le eraldi päringut
tegema ja kliendi privaatsus paraneb.[^5]

Esmalt kontrolli, kas serverisertifikaat sisaldab OCSP teenuse URI-d:

```bash
$ openssl x509 -in /etc/ssl/certs/Apache2404.pem -noout -ocsp_uri
```

Kui käsk tagastab toetatud URI, luba jagatud mälu vahemälu ja tootmiskeskkonna
tõrkekäitlus failis `/etc/apache2/mods-available/ssl.conf`:

```apache
SSLStaplingCache "shmcb:${APACHE_RUN_DIR}/ssl_stapling(32768)"
SSLStaplingReturnResponderErrors off
SSLStaplingResponderTimeout 4
SSLStaplingErrorCacheTimeout 60
```

Kontrolli, et `socache_shmcb` on lubatud, ning lisa HTTPS-virtuaalhosti
`SSLUseStapling On`. Ära luba stapling'ut, kui sertifikaadi väljastaja OCSP
teenust ei paku.

```bash
$ a2enmod socache_shmcb
$ systemctl restart apache2
$ openssl s_client -connect Apache2404.octox.demo:443 \
    -servername Apache2404.octox.demo -status </dev/null
```

Väljundis peab olema edukas OCSP vastus ja sertifikaadi olek `good`. Monitoori
vastuse uuendamise tõrkeid ning taga serveri ligipääs OCSP teenusele.

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

TLS protokollide valikul ei tohi tugineda Apache või operatsioonisüsteemi
vaikesätetele. Kehtiva seadistuse kontrollimiseks kasuta käsku:

```bash
$ grep -i -r "SSLProtocol" /etc/apache2/mods-available/
/etc/apache2/mods-available/ssl.conf:SSLProtocol all -SSLv3
```

TLS 1.0 ja TLS 1.1 tuleb keelata. Uutes ja ajakohastatud lahendustes tuleb
vaikimisi lubada ainult TLS 1.3. TLS 1.2 võib lisada üksnes dokumenteeritud
erandina, kui teenust peavad kasutama 2020. aasta või vanemad kliendid või
kui kliendisertifikaati peab küsima pärast esialgse TLS ühenduse loomist.
TLS 1.2 kasutamisel tuleb konfigureerida ka selge turvaliste
šifrikomplektide lubatud loend.

TLS 1.3 konfiguratsioon:

```apache
SSLProtocol -all +TLSv1.3
```

Dokumenteeritud ühilduvuserandi korral võib lubada TLS 1.2 ja TLS 1.3:

```apache
SSLProtocol -all +TLSv1.2 +TLSv1.3
```

Aruanne soovitab TLS 1.2 lubamisel korduskätluse keelata. Kui lahendus sõltub
kliendisertifikaadi küsimisest pärast esialgset kätlust, muudab korduskätluse
keelamine selle voo võimatuks. Eelista eraldi virtuaalhosti, mis küsib
sertifikaati esialgse kätluse ajal; ära säilita korduskätlust üksnes
asukohapõhise autentimisvoo jaoks.

Kui TLS-i teostus ja kasutatavad kliendid pakuvad tootmiskõlblikku tuge,
eelista hübriidrühma `X25519MLKEM768`. Juhend ei määra rühma seadistust
jäigalt, sest tugi ja standarditud identifikaator sõltuvad paigaldatud
OpenSSL-i versioonist. Enne sellele tuginemist kontrolli tegelikku rühma
ajakohase TLS-skanneriga.

Alternatiivina saab sama muudatuse teha serveripõhiselt konfigureerides
parameetrit `SSLProtocol` failis `/etc/apache2/mods-available/ssl.conf`.

Rohkem infot TLS protokolli kasutamise soovituste kohta leiab RIA
tellitud krüptograafiliste algoritmide elutsükli uuringust aadressil
<https://www.id.ee/artikkel/kruptograafiliste-algoritmide-elutsukli-uuringud-2/>.

##### Šifrikomplektid (*Cipher suites*)

OpenSSL-i aliastele, näiteks `HIGH`, tuginemise asemel tuleb
konfigureerida selge lubatud loend. TLS 1.3 jaoks luba järgmised
šifrikomplektid toodud järjekorras:

```apache
SSLCipherSuite TLSv1.3 "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"
```

`TLS_AES_128_CCM_SHA256` võib kasutada ainult varuvariandina, kui AES-GCM
ja ChaCha20-Poly1305 ei ole saadaval. CCM_8 komplekte ei tohi lubada.

Dokumenteeritud TLS 1.2 ühilduvuserandi korral luba ainult järgmised kolm
ECDHE-ECDSA ja AEAD šifrikomplekti. See vastab juhendis kasutatavale
ainult ECDSA sertifikaadi profiilile:

```apache
SSLCipherSuite SSL "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305"
```

Protokolli tähis `SSL` rakendub šifrikomplektidele kuni TLS 1.2-ni;
TLS 1.3 komplekte juhib eraldi `TLSv1.3` direktiiv. Kuna käesolev juhend
keelab vanemad protokollid, on `SSL` loend kasutatav ainult TLS 1.2-ga.
TLS 1.2 loend välistab RSA autentimise ja võtmevahetuse, staatilise DH/ECDH,
CBC, CCM_8 ja muud mitte-AEAD komplektid.

Alternatiivina saab kasutatavaid šifreid konfigureerida serveripõhiselt
failis `/etc/apache2/mods-available/ssl.conf` muutes selles parameetrit
`SSLCipherSuite`.

Kontrolli kehtivat loendit käsuga `openssl ciphers -v` ning testi pärast
iga muudatust ajakohase TLS skanneriga läbiräägitud protokolli ja
šifrikomplekti.

##### Pakkimine

Hoia TLS-i pakkimine selgesõnaliselt keelatuna:

```apache
SSLCompression off
```

HTTP vastuste pakkimine on TLS-i pakkimisest eraldiseisev ja võib saladusi
lekitada, kui vastus sisaldab nii ründaja juhitavat sisendit kui ka tundlikke
andmeid. Keela tundlike dünaamiliste vastuste jaoks `mod_deflate` ja
`mod_brotli`. Kui vastuste pakkimine peab jääma lubatuks, peab rakendus
takistama saitidevahelist päringuvõltsimist ning leevendama vastuse pikkuse
leket.

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

CA ahela usaldamine ei tõesta, et lõppsertifikaat on ID-kaardi
autentimissertifikaat. Erinevad sertifikaaditooted võivad kasutada sama juur-
või kesktaseme CA-d. Enne autenditud identiteedi aktsepteerimist tuleb nõuda,
et:

1.  Apache valideerib edukalt kogu sertifikaadiahela;
2.  väljastaja on selgesõnaliselt lubatud kesktaseme CA;
3.  `extendedKeyUsage` lubab TLS veebikliendi autentimist;
4.  lõppsertifikaadi laiendus `X509v3 CertificatePolicies` (`2.5.29.32`)
    sisaldab nii NCP+ autentimispoliitika OID-d kui ka sertifikaadi CA
    põlvkonnale vastavat lubatud dokumendipoliitika OID-d.[^6]

Käesolevas juhendis käsitletud tootmissertifikaatide lubatud loend on:

```text
# Nõutav igas aktsepteeritavas autentimissertifikaadis
0.4.0.2042.1.2

# ESTEID2018 - nõua üht neist dokumendipoliitika OID-dest
1.3.6.1.4.1.51361.1.1.1
1.3.6.1.4.1.51361.1.1.2
1.3.6.1.4.1.51361.1.1.3
1.3.6.1.4.1.51361.1.1.4
1.3.6.1.4.1.51361.1.1.5
1.3.6.1.4.1.51361.1.1.6
1.3.6.1.4.1.51361.1.1.7
1.3.6.1.4.1.51455.1.1.1

# ESTEID2025 - nõua üht neist dokumendipoliitika OID-dest
1.3.6.1.4.1.51361.2.1.1
1.3.6.1.4.1.51361.2.1.2
1.3.6.1.4.1.51361.2.1.3
1.3.6.1.4.1.51361.2.1.4
1.3.6.1.4.1.51361.2.1.5
1.3.6.1.4.1.51361.2.1.6
1.3.6.1.4.1.51455.2.1.1
```

Seosta dokumendipoliitika OID valideeritud väljastajaga: `ESTEID2018`
sertifikaati ei tohi aktsepteerida `ESTEID2025` poliitika OID alusel ega
vastupidi. Ühine NCP+ OID ei ole tootepõhine ja sellest üksi ei piisa.
Tootmise lubatud loendisse ei tohi lisada test-OID-sid, näiteks Zetesi OID-sid
prefiksiga `2.999`.

Järgmised väljastaja ja EKU kontrollid on kasulikud lisakaitsed, kuid ei
asenda sertifikaadipoliitika kontrolli:

```apache
<Location "/">
Require expr (
  (
    %{SSL_CLIENT_I_DN_CN} == "ESTEID2018"
    || %{SSL_CLIENT_I_DN_CN} == "ESTEID2025"
  )
  and (
    "TLS Web Client Authentication, E-mail Protection"
    in PeerExtList('extendedKeyUsage')
  )
)
</Location>
```

Konfiguratsiooni võib lisada virtuaalhosti või Apache üldkonfiguratsiooni.
Rakendus või autentimislüüs peab seejärel parsima valideeritud
lõppsertifikaati ja autentimise tagasi lükkama, kui selles ei ole nii NCP+
OID-d kui ka väljastajale vastavat dokumendipoliitika OID-d.
Sertifikaaditoodet ei tohi tuletada ainult subjekti, väljastaja või EKU järgi
ning `anyPolicy` OID-d (`2.5.29.32.0`) ei tohi käsitleda ID-kaardi poliitika
tõendina.

Kui rakendus on liidestatud CGI või mõne muu Apache keskkonnamuutujaid
kasutava liidese kaudu, teeb `SSLOptions +ExportCertData` PEM-kodeeritud
lõppsertifikaadi kättesaadavaks muutujas `SSL_CLIENT_CERT`. Muude liideste
puhul tuleb kasutada rakendusplatvormi TLS kliendisertifikaadi API-t.
Sertifikaadi andmeid tohib usaldada ainult kaitstud Apache ja rakenduse
vahelisest ühendusest; kliendi saadetud sertifikaadipäist ei tohi usaldada.

Eksporditud sertifikaadi laienduse kontrollimiseks testi:

```bash
$ openssl x509 -in client.pem -noout -text
```

Võrdle jaotist `X509v3 Certificate Policies` eespool viidatud kehtivate
poliitika- ja sertifikaadiprofiilide allikatega. Testi vähemalt üht
lubatud ID-kaardi sertifikaati ja seotud hierarhiates väljastatud muude
toodete sertifikaate, sealhulgas vajaduse korral Mobiil-ID-d.

> **Märkus:** Kui on kasutusel mõni muu liikluse filtreerimise vahend/võimalus, siis
> on soovitav turvaline konfiguratsioon juurutada ka seal. SK on F5
> konfiguratsiooni osas publitseerinud järgmise informatsiooni (vt.
> peakükki „Only accept certificates with trusted key usage"):
> <https://github.com/SK-EID/smart-id-documentation/wiki/Secure-Implementation-Guide>

> **Märkus:** SK soovitused turvaliseks autentimiseks ID-kaardiga on leitavad
> peatükist „Defence: implement ID-card authentication securely":
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

    # Serverisertifikaadi OCSP stapling - luba ainult CA OCSP toe korral
    # SSLUseStapling On

    # TLS häälestus — kasutada ainult TLS 1.3
    SSLProtocol -all +TLSv1.3
    SSLCipherSuite TLSv1.3 "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"
    # Dokumenteeritud ühilduvuserand TLS 1.2 jaoks:
    # SSLProtocol -all +TLSv1.2 +TLSv1.3
    # SSLCipherSuite SSL "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305"
    SSLHonorCipherOrder ON
    SSLCompression off

    # Kasutajale kuvatavate sertifikaatide filtreerimine
    SSLCADNRequestFile /etc/ssl/certs/DN_Bundle.pem

    # Kasutajasertifikaatide osaline filtreerimine; rakendus peab lisaks
    # lubama ainult ID-kaardi CertificatePolicies OID-d
    <Location "/">
    Require expr (
      (
        %{SSL_CLIENT_I_DN_CN} == "ESTEID2018"
        || %{SSL_CLIENT_I_DN_CN} == "ESTEID2025"
      )
      and (
        "TLS Web Client Authentication, E-mail Protection"
        in PeerExtList('extendedKeyUsage')
      )
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

[^3]: Kaasaegsed veebilehitsejad usaldavad sertifikaati ainult siis, kui
    veebilehe aadress vastab vähemalt ühele sertifikaadi SAN DNS nimele.

[^4]: Sertifikaatide kehtivust on võimalik kontrollida ka sertifikaatide
    tühistusnimekirjade (CRL) abil, ent sellel käesolevas dokumendis ei
    peatuta, kuna OCSP-põhine lahendus on eelistatum.

[^5]: <https://httpd.apache.org/docs/2.4/ssl/ssl_howto.html#ocspstapling>

[^6]: Lubatud loend põhineb
    [ESTEID2018 sertifitseerimispoliitikal v4.0](https://www.id.ee/wp-content/uploads/2025/10/cp_esteid_v4.0-08.10.2025.pdf),
    [ESTEID2025 sertifitseerimispoliitikal v2.0](https://repository.eidpki.ee/static/documents/eid-cp-v-2.0_04.06.2026_allkirjastatud.pdf)
    ja [Zetesi sertifikaadiprofiilidel](https://repository.eidpki.ee/static/documents/CertificateProfiles-20260520.pdf).
    Enne tootmise lubatud loendi muutmist kontrolli
    [Zetesi repositooriumi](https://repository.eidpki.ee/repository/) ning
    teenuseosutajate kehtivaid poliitikaid ja profiile.
