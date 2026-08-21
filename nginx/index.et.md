# Ubuntu Nginx veebiserveri kahepoolse SSLi häälestus Eesti ID‑kaartide vaates

**[In English](index.md)**

**Versioon:** 26.08/1

**Väljaandja:** [RIA](https://www.ria.ee/)

**Versiooni info**

| Kuupäev    | Versioon | Muutused/märkused
|:-----------|:--------:|:-----------------------------------------------------------
| 08.02.2019 | 19.02/1  | Avalik versioon.
| 28.02.2019 | 19.02/2  | Lisatud märkused kasutaja sertifikaatide kehtivuse kontrolli kohta. Vaikimisi veebilehe eemaldamine. — Muutja: Urmas Vanem
| 12.12.2019 | 19.12/1  | Lisatud Nginx soovituslikud turvasätted. — Muutja: Urmas Vanem
| 30.12.2020 | 20.12/1  | Ubuntu uuendatud versioonile 20.04.1. Nginx uuendatud versioonile 1.19.6. Muudetud konfiguratsiooni haldamine (sites-... -> conf.d). Lisatud OCSP-põhiste tühistusnimekirjade kasutamise võimalus, soovituslikud turvasätted ja valede CAde sertifikaatide blokeerimise kirjeldus. — Muutja: Urmas Vanem
| 13.01.2021 | 21.01/1  | Lisatud demo-konfiguratsiooni fail. Lisatud HSTS konfiguratsioon. — Muutja: Urmas Vanem
| 25.01.2021 | 21.01/2  | Muudetud HSTS, SSL/TLS ja šifrite kasutamise soovitusi, lisatud täiendava turvalisuse tõstmise soovitused. — Muutja: Urmas Vanem
| 28.04.2021 | 21.04/1  | Eemaldatud aegunud `ESTEID-SK 2011` sertifikaatide tugi. — Muutja: Urmas Vanem
| 25.11.2021 | 21.11/1  | Uuendatud Ubuntu platvorm versioonile Ubuntu Server 21.10 ja Nginx platvorm versioonile 1.21.4, lisatud ECC sertifikaatide loomine veebiserveril, täiendatud TLS ja Cipher soovitusi. — Muutja: Urmas Vanem
| 22.02.2023 | 23.02/1  | Ubuntu uuendatud versioonile Ubuntu Server 22.04 ja Nginx versioonile 1.23.3, uuendatud on ka virtuaalhosti konfiguratsioon. — Muutja: Urmas Vanem
| 18.12.2023 | 23.12/1  | Eemaldatud `ESTEID-SK 2015` ahel. — Muutja: Urmas Vanem
| 22.08.2024 | 24.08/1  | Ubuntu uuendatud versioonile Ubuntu Server 24.04 ja Nginx versioonile 1.27.1. — Muutja: Urmas Vanem
| 31.10.2025 | 25.10/1  | Lisatud Zetes ahelad, eemaldatud SK OCSP lõik. — Muutja: Lauris Kaplinski
| 22.04.2026 | 26.04/1  | Konverteeritud Markdown formaati. — Muutja: Raul Metsma
| 21.08.2026 | 26.08/1  | Uuendatud sertifikaadivõtme, TLS-protokollide, šifrikomplektide, sertifikaadipoliitikate ja OCSP juhiseid 2026. aasta krüptograafiliste algoritmide elutsükli aruande põhjal. — Muutja: Raul Metsma

---

- TOC
{:toc}

## Sissejuhatus

Käesolevas juhendis kirjeldatakse:

- Kuidas paigaldada ja häälestada Nginx 1.28.1 veebiserver Ubuntu 24.04 serveril.
- Kuidas häälestada HTTPS (ühepoolne SSL) veebiserveril.
- Kuidas häälestada [SK ID Solutions](https://www.skidsolutions.eu/resources/certificates/) (`EE-GovCA2018`) ja [Zetes](https://repository.eidpki.ee/) (`EEGovCA2025`) ID-kaartidega autentimine (kahepoolne SSL) veebiserveril.
- Kuidas kontrollida kliendisertifikaadi tühistusolekut ja häälestada
  serverisertifikaadi OCSP stapling.
- Kuidas turvata veebiserverit.

Lisaks on käsitletud muid konfiguratsioonivõimalusi, nt kuidas HTTP liiklus suunata HTTPS kanalisse jpm.

## Nginx paigaldus ja häälestus

### Paigaldus

Ubuntu 24.04 versiooni puhul paigaldatakse vaikimisi juhiste puhul Nginx versioon 1.24. Kuna juhendis kasutatakse viimast versiooni 1.28.1, siis tuleb enne paigaldust teha täiendavaid muudatusi.

Nginx versiooni 1.28.1 paigaldamiseks Ubuntu versioonile 24.04 tuleb teha järgmised sammud:

1.  Käivita terminalis käsk

    ```bash
    $ sudo add-apt-repository ppa:ondrej/nginx
    PPA publishes dbgsym, you may need to include 'main/debug' component
    Repository: 'Types: deb
    URIs: https://ppa.launchpadcontent.net/ondrej/nginx/ubuntu/
    Suites: noble
    Components: main
    '

    Description:
    This branch follows latest NGINX Stable packages compiled against latest OpenSSL for HTTP/2 and TLS 1.3 support.

    BUGS&FEATURES: This PPA now has a issue tracker: https://deb.sury.org/#bug-reporting
    ```

2.  Käivita terminalis käsk

    ```bash
    $ apt update
    Hit:1 http://ee.archive.ubuntu.com/ubuntu noble InRelease
    Hit:2 http://ee.archive.ubuntu.com/ubuntu noble-updates InRelease
    Hit:3 http://ee.archive.ubuntu.com/ubuntu noble-backports InRelease
    Hit:4 http://security.ubuntu.com/ubuntu noble-security InRelease
    Hit:5 https://ppa.launchpadcontent.net/ondrej/apache2/ubuntu noble InRelease
    Hit:6 https://ppa.launchpadcontent.net/ondrej/nginx-mainline/ubuntu noble InRelease
    ```

3.  Käivita terminalis käsk

    ```bash
    $ apt install nginx-full
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    The following additional packages will be installed:
      libnginx-mod-http-auth-pam libnginx-mod-http-dav-ext libnginx-mod-http-echo
      libnginx-mod-http-geoip2 libnginx-mod-http-subs-filter
      libnginx-mod-http-upstream-fair libnginx-mod-stream
      libnginx-mod-stream-geoip2 nginx nginx-common
    ```

Nginx versiooni saab kontrollida ka käsuga

```bash
$ nginx -v
nginx version: nginx/1.28.1
```

### Konfiguratsioon

#### Ühepoolse SSLi lubamine

##### SSL sertifikaadi privaatvõtme ja päringufaili (CSR) loomine

###### ECC (*Elliptic Curve Cryptography*)

Esmalt genereeri ECC privaatvõti, seejärel ECC CSR[^1]:

```bash
$ openssl ecparam -name secp384r1 -genkey -noout -out Nginx2404.key
$ openssl req -new -key Nginx2404.key -out Nginx2404.csr -subj /C=EE/O=OctoX/CN=Nginx2404.octox.demo -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:Nginx2404.octox.demo,DNS:MYWEBSERVER.octox.demo"))
```

1.  `Nginx2404.key` on sertifikaadi privaatvõti;
2.  `Nginx2404.csr` on sertifikaadi päringufail, mis edastatakse sertifitseerimiskeskusele;
3.  `CN=Nginx2404.octox.demo` on väljastatava sertifikaadi *common name;*
4.  `DNS:Nginx2404.octox.demo` ja `DNS:MYWEBSERVER.octox.demo` on sertifikaadil olevad SAN DNS nimed, mis peavad kindlasti vastama veebilehe tegelikule aadressile[^2]. Need nimed peavad ka nimeserveris lahenema.

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
$ openssl req -in Nginx2404.csr -noout -text
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: C = EE, O = OctoX, CN = Nginx2404.octox.demo
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (384 bit)
                pub:
                    04:83:8a:77:21:33:00:ac:6a:66:28:f4:7e:8e:98:
                    fa:52:09:ed:bb:83:f9:98:ee:24:3b:48:b1:e2:ad:
                    ae:1d:57:70:b1:9a:5c:c7:9c:4c:cb:95:f9:ff:b1:
                    89:4f:d0:c9:e1:39:0e:5d:ac:c6:d3:92:64:39:23:
                    5c:d0:fc:0e:38:17:22:3c:bb:e0:fb:ca:2c:8e:55:
                    65:2b:7c:56:6a:55:4a:b8:ae:a4:8c:e5:81:b7:a9:
                    d6:e4:5a:1a:aa:af:37
                ASN1 OID: secp384r1
                NIST CURVE: P-384
        Attributes:
            Requested Extensions:
                X509v3 Subject Alternative Name:
                    DNS:Nginx2404.octox.demo, DNS:MYWEBSERVER.octox.demo
        Signature Algorithm: ecdsa-with-SHA256
        Signature Value:
```

##### SSL sertifikaadi tellimine ja paigaldamine

Järgnevalt tuleb saata sertifikaadi päringufail `Nginx2404.csr` mõnele usaldusväärsele sertifitseerimiskeskusele allkirjastamiseks. Näidiskonfiguratsiooni tingimustes on sertifikaadi väljastajaks testkeskkonna sertifitseerimiskeskus. Allkirjastatud sertifikaat väljastatakse PEM formaadis:

```
-----BEGIN CERTIFICATE-----
MIICfjCCAZygAwIBAgITEQAAAAvIEFUdbDDF...
...
Hz3/vZjy73t2ag==
-----END CERTIFICATE-----
```

Avades sertifikaadi Ubuntu failihalduris on näha järgmist:

![ECC sertifikaat Ubuntu failihalduris](./img/image1.png)

Sertifikaadis on kirjas ka algoritm ja alternatiivsed subjekti DNS nimed:

![Sertifikaadi algoritm ja SAN DNS nimed](./img/image2.png)

Nagu näha, on sertifikaadi väljaandjaks sertifitseerimiskeskus nimega `Punane`. Nüüd tuleb hankida väljaandja CA sertifikaat PEM formaadis ja salvestada see kasutaja kodukausta nimega `Punane.pem`.

Koonda kõik ühepoolse SSL-i sertifikaadid ühte faili nii, et veebiserveri sertifikaat oleks esimene. Käesolevas näites tähendab see `Nginx2404.pem`-i, millele järgneb CA sertifikaat `Punane.pem`. Seda saab teha tekstiredaktoris (asetades Base64-kodeeritud sertifikaadid üksteise järele) või käsuga

```bash
$ cat Nginx2404.pem Punane.pem >Nginx2404_Bundle.pem
```

Ubuntus avades näeb koondfail välja järgmine:

![Sertifikaadid on koondatud ühte faili](./img/image3.png)

Sertifikaatide koondfaili `Nginx2404_Bundle.pem` tuleb kopeerida kausta `/etc/ssl/certs`. Lisaks peab
paigaldama ka sertifikaadi privaatvõtme kausta `/etc/ssl/private`.

```bash
$ cp Nginx2404_Bundle.pem /etc/ssl/certs
$ cp Nginx2404.key /etc/ssl/private
```

Nüüd on Nginx serveripoolsed sertifikaadid korrektselt failisüsteemi paigaldatud.

#### Virtuaalse veebilehe loomine

Loo enda konfiguratsioonile eraldiseisev virtuaalne veebileht. Esmalt tuleb luua kaust `/var/www/Nginx2404`, kuhu paigaldada veebilehe sisu.

```bash
$ mkdir /var/www/Nginx2404
```

Paigalda loodud kausta mõni lihtne ja äratuntav veebileht nimega `index.html`.

Järgmiseks tee valmis virtuaalse veebilehe konfiguratsioonifail. Tee uus fail nimega `/etc/nginx/conf.d/Nginx2404.conf` (näiteks käsuga `nano /etc/nginx/conf.d/Nginx2404.conf`).

Nüüd muuda uut konfiguratsioonifaili vastavalt oma soovidele. Lisa sinna järgmine sisu[^3]:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name Nginx2404.octox.demo;
    return 301 https://Nginx2404.octox.demo;
}

server {
    # SSL configuration
    listen 443 ssl;
    listen [::]:443 ssl;
    root /var/www/Nginx2404;
    index index.html;
    server_name Nginx2404.octox.demo;

    # Certificates
    ssl_certificate /etc/ssl/certs/Nginx2404_Bundle.pem;
    ssl_certificate_key /etc/ssl/private/Nginx2404.key;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Konfiguratsiooni süntaksit saab kontrollida käsuga `nginx -t`. Kui vigu ei ole, käivita Nginx teenus:

```bash
$ systemctl start nginx
```

Kui teenus juba töötab, saab muudatused rakendada käsuga

```bash
$ systemctl reload nginx
```

#### Tulemus

Nüüd saab veebilehe poole pöördumiseks kasutada ühepoolset SSLi. Samuti suunatakse automaatselt aadressilt <http://Nginx2404.octox.demo> aadressile <https://Nginx2404.octox.demo>.

![Nginx veebiserver töötab ühepoolse SSLiga](./img/image4.png)

#### Kahepoolse sertifikaadinõude (SSLi) kehtestamine

Eesti ID-kaardiga autentimise lubamiseks tuleb olemasolevat konfiguratsiooni pisut täiendada.

Lisa järgmised read `Nginx2404.conf` faili SSL sektsiooni, pärast `ssl_certificate_key` rida:

```nginx
# Certificates
ssl_certificate /etc/ssl/certs/Nginx2404_Bundle.pem;
ssl_certificate_key /etc/ssl/private/Nginx2404.key;
ssl_client_certificate /etc/ssl/certs/EID_Bundle.pem;
ssl_verify_client on;
ssl_verify_depth 2;
```

Nüüd tuleb luua uus tekstifail [`EID_Bundle.pem`](#eid_bundle.pem), kuhu tuleb lisada eID juur- ja kesktaseme sertifikaadid Base64 kodeeritud kujul (`EE-GovCA2018`, `ESTEID2018`, `EEGovCA2025`, `ESTEID2025`). Selle faili abil saab välja filtreerida kõik sertifitseerimiskeskused, mille alt väljastatud sertifikaate uus veebileht toetab. Kasutajale näidatakse vaid neid sertifikaate, mis on väljastatud eelloetletud ahelatest. Faili loomiseks saab kasutada cat käsku, aga töötab ka kopeeri-ja-kleebi tekstiredaktorite vahel. Ubuntus avatuna näeb fail välja järgmine:

![Juur- ja kesktaseme sertifikaadid ühes failis](./img/image5.png)

Salvesta loodud faili nimega [`EID_Bundle.pem`](#eid_bundle.pem) ja kopeeri see kausta `/etc/ssl/certs`. Veebiserveris muudatuse jõustumiseks taaskäivita Nginx:

```bash
$ systemctl reload nginx
```

Pöördudes pärast muudatuse jõustumist uuesti veebilehe `Nginx2404.octox.demo` poole, küsitakse kasutaja sertifikaati.

![Kasutaja sertifikaadi valikudialoog](./img/image6.png)

Server pakub kasutajale välja sertifikaadid, mille väljastajad on kirjeldatud failis [`EID_Bundle.pem`](#eid_bundle.pem). Pärast sertifikaadi kinnitamist ja PIN-koodi sisestamist lubatakse kasutaja veebilehele - kahepoolne SSL töötab.

Käesoleva dokumendi kõiki sätteid koondav demo-konfiguratsioonifail on saadaval [lisas](#nginx_eid_demo.conf).

## Võimalikud lisakonfiguratsioonid

Käesoleva dokumendi eesmärk ei ole anda täpseid juhiseid optimaalseks veebilehtede konfigureerimiseks ega turvamiseks, vaid tutvustada konfiguratsiooni kahepoolse SSLi kasutamiseks Eesti ID-kaartidega. Siiski on oluline arvestada allolevaga.

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

OCSP (*Online Certificate Status Protocol*) võimaldab Nginxil kontrollida
kliendisertifikaadi tühistusolekut autentimise ajal.

CA-de `ESTEID2018` ja `ESTEID2025` väljastatud sertifikaatides on AIA OCSP
teenuse aadress (<http://aia.sk.ee/esteid2018> ja
<http://ocsp.eidpki.ee>).

![ESTEID2018 AIA OCSP aadress sertifikaadis](./img/image7.png)

Lubamaks kasutaja sertifikaadi staatuse kontrolli vastu sertifikaadis olevat AIA OCSP teenust, tuleb Nginx SSL konfiguratsiooni lisada järgmised read pärast `ssl_verify_depth` rida:

```nginx
# Certificates
ssl_certificate /etc/ssl/certs/Nginx2404_Bundle.pem;
ssl_certificate_key /etc/ssl/private/Nginx2404.key;
ssl_client_certificate /etc/ssl/certs/EID_Bundle.pem;
ssl_verify_client on;
ssl_verify_depth 2;
ssl_ocsp leaf;
ssl_ocsp_cache shared:OCSP:10m;
resolver 194.126.115.18;
```

Väärtus `leaf` kontrollib lõppkasutaja sertifikaati ja jagatud vahemälu
vähendab korduvaid päringuid. OCSP teenuse aadress võetakse
kliendisertifikaadist. Asenda `resolver` IP-aadress avalikke aadresse lahendava
DNS-serveri IP-aadressiga[^5]. Luba serverist väljuv DNS- ja HTTP-liiklus OCSP
teenustesse ning monitoori Nginxi tõrkeid: OCSP kontrolli ebaõnnestumisel
kliendisertifikaadiga autentimine ei õnnestu.

### Serverisertifikaadi OCSP vastuse stapling

Eespool kirjeldatud kliendisertifikaadi kontroll ja serverisertifikaadi OCSP
stapling on eri funktsioonid. Stapling võimaldab Nginxil hankida oma
serverisertifikaadi kohta allkirjastatud olekuvastuse ja saata selle TLS
kätluse ajal. Nii ei pea iga veebilehitseja väljastanud CA-le eraldi päringut
tegema ja kliendi privaatsus paraneb.[^6]

Esmalt kontrolli, kas serverisertifikaat sisaldab OCSP teenuse URI-d:

```bash
$ openssl x509 -in /etc/ssl/certs/Nginx2404_Bundle.pem -noout -ocsp_uri
```

Kui käsk tagastab toetatud URI, loo PEM-vormingus fail
`/etc/ssl/certs/Nginx2404_CA.pem`, mis sisaldab väljastaja, kesktaseme ja
juur-CA sertifikaate. Seejärel luba stapling ja vastuse kontroll:

```nginx
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /etc/ssl/certs/Nginx2404_CA.pem;
resolver 194.126.115.18;
```

Ära luba stapling'ut, kui sertifikaadi väljastaja OCSP teenust ei paku. Pärast
Nginxi konfiguratsiooni taaslaadimist kontrolli kaasatud OCSP vastust:

```bash
$ openssl s_client -connect Nginx2404.octox.demo:443 \
    -servername Nginx2404.octox.demo -status </dev/null
```

Väljundis peab olema edukas OCSP vastus ja sertifikaadi olek `good`. Monitoori
vastuse uuendamise tõrkeid ning taga serveri ligipääs OCSP teenusele.

### Soovituslikud Nginxi turvasätted

#### SSL/TLS

TLS protokollide valikul ei tohi tugineda Nginxi või operatsioonisüsteemi
vaikesätetele. TLS 1.0 ja TLS 1.1 tuleb keelata. Uutes ja ajakohastatud
lahendustes tuleb vaikimisi lubada ainult TLS 1.3.

TLS 1.2 võib lisada üksnes dokumenteeritud erandina, kui teenust peavad
kasutama 2020. aasta või vanemad kliendid või kui kliendisertifikaati
peab küsima pärast esialgse TLS ühenduse loomist. TLS 1.2 kasutamisel
tuleb konfigureerida ka selge turvaliste šifrikomplektide lubatud loend.

TLS 1.3 konfiguratsioon:

```nginx
ssl_protocols TLSv1.3;
```

Dokumenteeritud ühilduvuserandi korral võib lubada TLS 1.2 ja TLS 1.3:

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
```

Nginx küsib kliendisertifikaati esialgse kätluse ajal, seega ei vaja selle
juhendi autentimisvoog TLS 1.2 korduskätlust. Alltoodud konfiguratsioon
keelab selle selgesõnaliselt.

Kui TLS-i teostus ja kasutatavad kliendid pakuvad tootmiskõlblikku tuge,
eelista hübriidrühma `X25519MLKEM768`. Juhend ei määra rühma seadistust
jäigalt, sest tugi ja standarditud identifikaator sõltuvad paigaldatud
OpenSSL-i versioonist. Enne sellele tuginemist kontrolli tegelikku rühma
ajakohase TLS-skanneriga.

Sama muudatuse serveri tasemel kehtestamiseks muuda `ssl_protocols`
direktiivi failis `/etc/nginx/nginx.conf`.

Rohkem infot TLS protokolli kasutamise soovituste kohta leiab RIA
tellitud krüptograafiliste algoritmide elutsükli uuringust aadressil
<https://www.id.ee/artikkel/kruptograafiliste-algoritmide-elutsukli-uuringud-2/>.

#### Šifrikomplektid (*Cipher suites*)

OpenSSL-i aliastele, näiteks `HIGH`, tuginemise asemel tuleb konfigureerida
selge lubatud loend. TLS 1.3 jaoks luba järgmised šifrikomplektid toodud
järjekorras:

```nginx
ssl_conf_command Ciphersuites TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256;
```

`TLS_AES_128_CCM_SHA256` võib kasutada ainult varuvariandina, kui AES-GCM
ja ChaCha20-Poly1305 ei ole saadaval. CCM_8 komplekte ei tohi lubada.

Dokumenteeritud TLS 1.2 ühilduvuserandi korral luba ainult järgmised kolm
ECDHE-ECDSA ja AEAD šifrikomplekti. See vastab juhendis kasutatavale
ainult ECDSA sertifikaadi profiilile:

```nginx
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305';
```

Direktiiv `ssl_ciphers` juhib TLS 1.2 ja vanemaid versioone;
`ssl_conf_command Ciphersuites` juhib OpenSSL-i kaudu TLS 1.3 komplekte.
TLS 1.2 loend välistab RSA autentimise ja võtmevahetuse, staatilise DH/ECDH,
CBC, CCM_8 ja muud mitte-AEAD komplektid.

Neid direktiive saab konfigureerida ka serveripõhiselt failis
`/etc/nginx/nginx.conf`. Kontrolli kehtivat loendit käsuga
`openssl ciphers -v` ning testi pärast iga muudatust ajakohase TLS
skanneriga läbiräägitud protokolli ja šifrikomplekti.

##### Pakkimine ja korduskätlus

Hoia TLS-i pakkimine ja TLS 1.2 korduskätlus selgesõnaliselt keelatuna:

```nginx
ssl_conf_command Options -Compression,NoRenegotiation;
```

HTTP vastuste pakkimine on TLS-i pakkimisest eraldiseisev ja võib saladusi
lekitada, kui vastus sisaldab nii ründaja juhitavat sisendit kui ka tundlikke
andmeid. Määra tundlikes dünaamilistes asukohtades `gzip off;` ja keela seal
ka seadistatud Brotli moodul. Kui vastuste pakkimine peab jääma lubatuks,
peab rakendus takistama saitidevahelist päringuvõltsimist ning leevendama
vastuse pikkuse leket.

Rohkem infot šifrikomplektide soovituste kohta leiab RIA tellitud
krüptograafiliste algoritmide elutsükli uuringust aadressil
<https://www.id.ee/artikkel/kruptograafiliste-algoritmide-elutsukli-uuringud-2/>.

##### ssl_prefer_server_ciphers

Eelistamaks serveri šifrikomplektide valikut kasutaja omale, tuleb Nginx
konfiguratsioonifailis defineerida määrang `ssl_prefer_server_ciphers`
ja panna selle väärtuseks `on`.

#### Kasutajasertifikaatide lisafiltreerimine

CA ahela usaldamine ei tõesta, et lõppsertifikaat on ID-kaardi
autentimissertifikaat. Erinevad sertifikaaditooted võivad kasutada sama juur-
või kesktaseme CA-d. Enne autenditud identiteedi aktsepteerimist tuleb nõuda,
et:

1.  Nginx valideerib edukalt kogu sertifikaadiahela;
2.  väljastaja on selgesõnaliselt lubatud kesktaseme CA;
3.  `extendedKeyUsage` lubab TLS veebikliendi autentimist;
4.  lõppsertifikaadi laiendus `X509v3 CertificatePolicies` (`2.5.29.32`)
    sisaldab nii NCP+ autentimispoliitika OID-d kui ka sertifikaadi CA
    põlvkonnale vastavat lubatud dokumendipoliitika OID-d.[^7]

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

Nginxil ei ole direktiivi, mis suudaks `CertificatePolicies` laienduse
poliitika OID-de lubatud loendit usaldusväärselt rakendada. Kontroll tuleb
teha rakenduses või autentimislüüsis. Sertifikaaditoodet ei tohi tuletada
ainult subjekti, väljastaja või EKU järgi ning `anyPolicy` OID-d
(`2.5.29.32.0`) ei tohi käsitleda ID-kaardi poliitika tõendina.

Esialgse lisakaitsena lükka tagasi sertifikaadid, mille väljastaja CA nimi ei
ole `ESTEID2018` ega `ESTEID2025`. Lisa järgmised tingimused pärast TLS-i
konfiguratsiooni `server`-sektsiooni:

```nginx
# Esialgne filter kesktaseme CA nime järgi
set $trusted_client_issuer 0;

if ($ssl_client_i_dn ~ "^CN=ESTEID2018,") {
    set $trusted_client_issuer 1;
}

if ($ssl_client_i_dn ~ "^CN=ESTEID2025,") {
    set $trusted_client_issuer 1;
}

if ($trusted_client_issuer = 0) {
    return 403;
}
```

Nende tingimustega lükkab Nginx sertifikaadi tagasi, kui selle väljastaja ei
ole `ESTEID2018` ega `ESTEID2025`. Väljastaja kontroll ei asenda
sertifikaadipoliitika kontrolli.

HTTP upstream'i puhul kirjuta valideeritud lõppsertifikaat selleks ettenähtud
päisesse:

```nginx
proxy_set_header X-Client-Certificate $ssl_client_escaped_cert;
```

Rakendus peab sertifikaadi URL-dekodeerima ja parsima ning autentimise tagasi
lükkama, kui selles ei ole nii NCP+ OID-d kui ka väljastajale vastavat
dokumendipoliitika OID-d. Päist tohib usaldada ainult siis, kui rakendus on
ligipääsetav üksnes usaldatud Nginxi proksi kaudu. Muude liideste puhul tuleb
kasutada rakendusplatvormi TLS kliendisertifikaadi integratsiooni.

Eksporditud sertifikaadi laienduse kontrollimiseks testi:

```bash
$ openssl x509 -in client.pem -noout -text
```

Võrdle jaotist `X509v3 Certificate Policies` eespool viidatud kehtivate
poliitika- ja sertifikaadiprofiilide allikatega. Testi vähemalt üht
lubatud ID-kaardi sertifikaati ja seotud hierarhiates väljastatud muude
toodete sertifikaate, sealhulgas vajaduse korral Mobiil-ID-d.

> **Märkus:** Kui on kasutusel mõni muu liikluse filtreerimise vahend/võimalus, siis on soovitav turvaline konfiguratsioon juurutada ka seal. SK on F5 konfiguratsiooni osas publitseerinud järgmise informatsiooni (vt. peakükki „Only accept certificates with trusted key usage"): <https://github.com/SK-EID/smart-id-documentation/wiki/Secure-Implementation-Guide>

> **Märkus:** SK soovitused turvaliseks autentimiseks ID-kaardiga on leitavad peatükist „Defence: implement ID-card authentication securely": <https://github.com/SK-EID/smart-id-documentation/wiki/Secure-Implementation-Guide>

#### *HTTP Strict Transport Security* (HSTS) lubamine

HSTS teenuse Nginx veebilehele konfigureerimiseks lisa konfiguratsioonifaili rida `add_header Strict-Transport-Security`:

```nginx
# Other recommended security and optimization settings.
ssl_prefer_server_ciphers on;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
ssl_session_cache    shared:SSL:10m;
ssl_session_timeout  1h;
ssl_session_tickets  on;
```

#### Muud võimalused

Lisaks TLS ja šifrikomplektide häälestusele on soovitav pöörata tähelepanu Nginx serveri turvalisusele ka järgmiste punktide vaates:

- Hoida operatsioonisüsteem uuendatuna.
- Hoida Nginx uuendatuna.
- Keelata serveri info presenteerimine.
- Keelata HTTP päringud.
- Paigaldada ja konfigureerida Naxsi.
- Monitoorida Monit abil.
- Konfigureerida X-XSS kaitse.
- Konfigureerida X-Frame-Options.
- Konfigureerida X-Content-Type-Options.
- Konfigureerida Content Security Policy (CSP).
- ...

Ülaltoodu on näidisloend võimalustest Nginx turvalisemaks muutmiseks. Põhjalikumaid soovitusi on võimalik leida internetist: <https://www.google.com/search?q=how+to+secure+nginx+server>.

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

### Nginx_EID_Demo.conf

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name Nginx2404.octox.demo;
    return 301 https://Nginx2404.octox.demo;
}

server {
    # SSL configuration
    listen 443 ssl;
    listen [::]:443 ssl;
    root /var/www/Nginx2404;
    index index.html;
    server_name Nginx2404.octox.demo;

    # Certificates
    ssl_certificate /etc/ssl/certs/Nginx2404_Bundle.pem;
    ssl_certificate_key /etc/ssl/private/Nginx2404.key;
    ssl_client_certificate /etc/ssl/certs/EID_Bundle.pem;
    ssl_verify_client on;
    ssl_verify_depth 2;

    # Kliendisertifikaadi tühistusoleku kontroll
    ssl_ocsp leaf;
    ssl_ocsp_cache shared:OCSP:10m;
    resolver 194.126.115.18;

    # Serverisertifikaadi OCSP stapling - luba ainult CA OCSP toe korral
    # ssl_stapling on;
    # ssl_stapling_verify on;
    # ssl_trusted_certificate /etc/ssl/certs/Nginx2404_CA.pem;

    # TLS
    ssl_protocols TLSv1.3;
    ssl_conf_command Ciphersuites TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256;
    # Dokumenteeritud ühilduvuserand TLS 1.2 jaoks:
    # ssl_protocols TLSv1.2 TLSv1.3;
    # ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305';
    ssl_conf_command Options -Compression,NoRenegotiation;
    ssl_prefer_server_ciphers on;

    # HSTS and session settings
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    ssl_session_cache    shared:SSL:10m;
    ssl_session_timeout  1h;
    ssl_session_tickets  on;

    # Osaline filtreerimine väljastaja CA nime järgi; rakendus peab lisaks
    # lubama ainult ID-kaardi CertificatePolicies OID-d
    set $trusted_client_issuer 0;

    if ($ssl_client_i_dn ~ "^CN=ESTEID2018,") {
        set $trusted_client_issuer 1;
    }

    if ($ssl_client_i_dn ~ "^CN=ESTEID2025,") {
        set $trusted_client_issuer 1;
    }

    if ($trusted_client_issuer = 0) {
        return 403;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
```

[^1]: Lisaks käsureal kirjeldatud sertifikaadi atribuutidele C, O ja CN on võimalik soovi korral lisaks kirjeldada atribuudid L, OU ja S. Võib kasutada ka ainult CNi.

[^2]: Kaasaegsed veebilehitsejad usaldavad sertifikaati ainult siis, kui veebilehe aadress vastab vähemalt ühele sertifikaadi SAN DNS nimele.

[^3]: HTTP osa siin konfiguratsioonifailis ei ole tegelikult vajalik ja on toodud lihtsalt HTTP -\>HTTPS ümbersuunamise näitena.

[^4]: Sertifikaatide kehtivust on võimalik kontrollida ka sertifikaatide tühistusnimekirjade (CRL) abil, ent sellel käesolevas dokumendis ei peatuta, kuna OCSP-põhine lahendus on eelistatum.

[^5]: *Resolver* -- asendage see soovi korral mõne DNS serveriga, mis on võimeline avalikke DNS aadresse lahendama. Selliseks serveriks võib olla ka teie enda sisevõrgu DNS server.

[^6]: <https://nginx.org/en/docs/http/ngx_http_ssl_module.html>

[^7]: Lubatud loend põhineb
    [ESTEID2018 sertifitseerimispoliitikal v4.0](https://www.id.ee/wp-content/uploads/2025/10/cp_esteid_v4.0-08.10.2025.pdf),
    [ESTEID2025 sertifitseerimispoliitikal v2.0](https://repository.eidpki.ee/static/documents/eid-cp-v-2.0_04.06.2026_allkirjastatud.pdf)
    ja [Zetesi sertifikaadiprofiilidel](https://repository.eidpki.ee/static/documents/CertificateProfiles-20260520.pdf).
    Enne tootmise lubatud loendi muutmist kontrolli
    [Zetesi repositooriumi](https://repository.eidpki.ee/repository/) ning
    teenuseosutajate kehtivaid poliitikaid ja profiile.
