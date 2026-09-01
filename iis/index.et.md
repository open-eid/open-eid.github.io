# IIS veebiserverile ID-kaardi toe seadistamine

**[In English](index.md)**

**Versioon:** 26.08/1

**Väljaandja:** [RIA](https://www.ria.ee/)

**Versiooni info**

| Kuupäev    | Versioon | Muutused/märkused
|:-----------|:--------:|:-----------------------------------------------------------
| 21.01.2019 | 19.01/1  | Avalik versioon, baseerub `18.12` tarkvaral.
| 12.02.2019 | 19.02/1  | Lisatud OCSP konfiguratsioonivõimalused. — Muutja: Urmas Vanem
| 01.10.2019 | 19.10/1  | Lisatud info Windows serveri (IIS) paranduste staatuse ja tulevase kättesaadavuse osas versioonide lõikes. Vt. sissejuhatuse viimane lõik. — Muutja: Urmas Vanem
| 18.10.2019 | 19.10/2  | Kirjeldatud Windows Server 2016 uuendus `KB4516061`, mis lahendab Chrome-IIS probleemi. — Muutja: Urmas Vanem
| 08.11.2019 | 19.11/1  | Kirjeldatud Windows Server 2019 uuendus `KB4520062`, mis lahendab Chrome-IIS probleemi. — Muutja: Urmas Vanem
| 14.11.2019 | 19.11/2  | Kirjeldatud Windows Server 1903 (SAC) uuendus `KB4524570`, mis lahendab Chrome-IIS probleemi. — Muutja: Urmas Vanem
| 12.12.2019 | 19.12/1  | Lisatud soovitused IIS'i turvamiseks. — Muutja: Urmas Vanem
| 14.12.2020 | 20.12/1  | Lisatud turvasätted ebasoovitavate CA-de ligipääsu piiramiseks. — Muutja: Urmas Vanem
| 17.12.2020 | 20.12/2  | Lisatud mõned turvasoovitused peatükki „Ebavajalike CA-de juurdepääsu piiramine". — Muutja: Urmas Vanem
| 03.03.2021 | 21.03/1  | Eemaldatud aegunud IIS ja Google Chrome autentimise probleem ning täpsustatud infot. — Muutja: Kristjan Vaikla
| 30.04.2021 | 21.04/1  | Eemaldatud aegunud `ESTEID-SK 2011` sertifikaatide tugi. — Muutja: Urmas Vanem
| 14.12.2021 | 21.12/1  | Muudetud Windows platvorm versioonile Server 2022. Lisatud kolmandalt osapoolelt ECDSA algoritmil põhineva sertifikaadi päringu protseduur. Täiendatud on TLS ja Cipher soovitusi. — Muutja: Urmas Vanem
| 18.01.2022 | 22.01/1  | Lisatud Windows Server 2022 ja `TLS 1.3` protokolliga seotud informatsioon, k.a. in-handshake autentimismeetodi konfigureerimise protseduur sertifikaadiga autentimise lubamiseks `TLS 1.3` protokolliga. — Muutja: Urmas Vanem
| 18.12.2023 | 23.12/1  | Eemaldatud `ESTEID-SK 2015` ahel. — Muutja: Urmas Vanem
| 31.10.2025 | 25.10/1  | Lisatud Zetes ahelad. — Muutja: Raul Kaidro
| 22.04.2026 | 26.04/1  | Konverteeritud Markdown formaati. — Muutja: Raul Metsma
| 21.08.2026 | 26.08/1  | Uuendatud platvorm Windows Server 2025 versioonile ning sertifikaadivõtme, TLS-i, šifrikomplektide, sertifikaadipoliitikate ja OCSP juhiseid 2026. aasta krüptograafiliste algoritmide elutsükli aruande põhjal. — Muutja: Raul Metsma

Juhend, kuidas autentida kasutajat IIS veebiserveril Eesti eID kaartidega.

---

- TOC
{:toc}

## Sissejuhatus

Käesolev juhend kirjeldab IIS veebiserveri konfiguratsiooni kahepoolse SSL-i kasutamiseks, kus kliendi poolseks sertifikaadiks on Eesti eID kaardile (ID-kaart, elamisloakaart, digi-ID ja e-residendi digi-ID) väljastatud sertifikaat.

Juhendi serveriplatvorm on Windows Server 2025; kliendi poolel kasutatakse
Windows 10 operatsioonisüsteemi. Näidisjuhendis toetatakse
[SK ID Solutions](https://www.skidsolutions.eu/resources/certificates/)
`EE-GovCA2018` ja [Zetes](https://repository.eidpki.ee/) `EEGovCA2025`
ahelast pärinevaid sertifikaate. Kliendi poolel on kiipkaardi sertifikaadi
äratundmiseks vajalik ka ID-tarkvara[^1]. Näidisjuhendi serveri sertifikaat
on väljastatud OctoX testkeskkonnast.

IIS kasutamisel on võimalik rakendada erinevaid autentimismeetodeid. Käesolev dokument vaatleb sertifikaadi nõude kehtestamist IIS anonüümse autentimise jaoks – st. peale sertifikaadi kehtivuse kontrolli lubatakse kasutaja eelnevalt määratud kasutaja (IUSR) õigustes veebisaidile ligi.

Hetkel on testid edukalt läbi viidud järgmiste brauseritega (viimased versioonid):

1.  Microsoft Edge
2.  Mozilla Firefox
3.  Google Chrome

## Ühepoolse SSL/TLS-i konfigureerimine

### Windows serveri sertifikaadi konfiguratsioon

Pakkumaks turvalist veebiteenust peab IIS serverile olema määratud TLS sertifikaat — käesolevas näites on kasutusel OctoX testkeskkonnast väljastatud sertifikaat. Samuti peavad nii kliendid kui ka veebiserver ise usaldama nimetatud sertifikaati.

Domeeni keskkonnas ja domeeni (*enterprise*) CA olemasolul on tõenäoliselt kõige mõistlikum küsida ka serveri sertifikaat domeeni CA-lt. Ent juhul, kui meid ei rahulda domeeni taseme turvalisus ja võimalused või kui vajame sertifikaati, mis on laiemalt usaldatud, tuleb luua privaatvõti ning sertifikaadi päring ja lasta viimase alusel luua sertifikaat mõnel üldtuntud CA-l.

#### Serveri sertifikaadi hankimine

Kuna IIS halduskonsoolilt loodav sertifikaadi päring on üsna piiratud võimalustega, kasutatakse serveri sertifikaadi loomiseks hoopis sertifikaatide halduskonsooli. Käivitage IIS serveril `mmc.exe` ja lisage sinna lokaalse arvuti sertifikaadid. Looge kohandatud päring:

![Alustame kohandatud päringu loomisega](./img/image1.png)

Klikkige kolm korda *Next* ja valige *Details, Properties.* Avaneb sertifikaadi päringu omaduste aken:

![Sertifikaadi päringu omaduste aken](./img/image2.png)

Järgnevalt on võimalik määrata päringufailile täpsed omadused, milliseid soovitakse hiljem veebiserveri sertifikaadi juures näha.

Juhul, kui sarnaseid päringufaile on tarvis tihedamini luua, soovitatakse tegevuse automatiseerimiseks tutvuda `PowerShell` võimalustega.

##### Sakk General

Siin on võimalik määrata soovi korral sertifikaadi hüüdnimi ja põgus kirjeldus. Need väljad ei ole sertifikaadi sisulised osad ja omavad tähendust selgituse, hilisema lihtsama arusaama mõttes.

![Sertifikaadi üldinfo](./img/image3.png)

##### Sakk Subject

Aknas *Subject* kirjeldatakse subjekt nagu ikka. Kui soovitakse kasutada erinevaid SAN DNS nimesid või *common name* puhul kasutatakse midagi muud kui FQDN, siis tuleb üks või mitu DNS aliast siin ka kirjeldada.

![Subjekti näidiskonfiguratsioon](./img/image4.png)

##### Sakk Extensions

Aknas *Extensions* tuleb määrata järgmised omadused:

1.  Key Usage:
    1.  Digital signature;
    2.  Key encipherment.
2.  Extended Key Usage:
    1.  Server Authentication.

![Laienduste määramine](./img/image5.png)

##### Sakk Private Key

Siit aknast valitakse CSP ehk sertifikaadi võtmete algoritm.
Näidiskonfiguratsioonis eemaldatakse RSA valik ja valitakse `ECDSA_P384`.

![ECDSA P-384 CSP valimine](./img/image6.png)

Genereeri igale sõltumatule TLS-serverile eraldi privaatvõti. Ära kopeeri
sama võtit mitmesse serverisse üksnes seetõttu, et metamärgiga või mitme SAN
nimega sertifikaat kataks kõik serverinimed. Eraldi võtmed piiravad serveri
või võtme kompromiteerumise mõju.

Tootmislahenduses kasuta võimaluse korral füüsilist turvamoodulit (HSM) või
samaväärset mitteeksporditava võtmega riistvaralist võtmepakkujat. Genereeri
võti seadmes ja hoia see mitteeksporditavana. Enne kasutuselevõttu veendu, et
HSM-i võtmepakkuja, IIS ja sertifikaadi väljastaja toetavad valitud ECDSA
P-384 võtit. Siin näidatud tarkvaralise võtmepakkuja töövoog ei ole HSM-i
seadistus.

Klikkige *OK* ja *Next*, määrake kaust ning nimi ja salvestage sertifikaadi päring `Base64` formaadis.

Kontrolli värskelt loodud sertifikaadi päringufaili `certutil` abil:

```bat
certutil -dump iis2112.req
```

Oluline väljund peaks sarnanema järgmisega; päringuspetsiifilised räsid ja
avaliku võtme toorbaidid on välja jäetud:

```text
PKCS10 Certificate Request:
Version: 1
Subject:
    CN=iis2111.kaheksa.xi
    C=EE
    O=OctoX
    OU=DEV

Public Key Algorithm:
    Algorithm ObjectId: 1.2.840.10045.2.1 ECC
    Algorithm Parameters:
        1.3.132.0.34 ECDH_P384
Public Key Length: 384 bits

Subject Alternative Name
    DNS Name=iis2112.kaheksa.xi
    DNS Name=iis2111.kaheksa.xi
    DNS Name=MyWebServer.kaheksa.xi
```

Kontrolli, et avalik võti on 384-bitine ja kõik vajalikud DNS-nimed on
jaotises `Subject Alternative Name` olemas.

Sertifikaadi päringufail edastatakse mõnele CA serverile, paludes selle alusel sertifikaat genereerida. Tulemus on järgmine:

![IIS serveri sertifikaat](./img/image9.png)

#### Sertifikaadi installeerimine

IIS server peab usaldama sertifikaati `OctoX Demo CA 21.11`, mis on serveri
sertifikaadi väljastajaks. Selleks tuleb kontrollida selle sertifikaadi
olemasolu *usaldusväärsete juursertifikaatide* (*Trusted Root Certification
Authorities*) konteineris. Kui väljastaja CA sertifikaat sealt puudub, tuleb
see lisada![^2]

![IIS server usaldab temale sertifikaadi väljastanud CA-d.](./img/image10.png)

IIS serveri sertifikaat ise tuleb paigaldada IIS serveril lokaalse arvuti personaalsesse konteinerisse:

![Avades sertifikaadi näeme, et IIS serveril on ka selle privaatvõti kasutada!](./img/image11.png)

### Ühepoolse SSL-konfiguratsiooni loomine

Ühepoolse TLS-i konfigureerimiseks lisa HTTPS-seos (tavaliselt port 443),
vali serveri sertifikaat ja keela pärand-TLS-protokollid.

Järgmisel ekraanipildil on Windows Server 2025 seose olulised seadistused.
Vali serveri sertifikaat, hoia *Disable Legacy TLS* märgituna ja jäta
*Disable TLS 1.3 over TCP* märkimata.

![Windows Server 2025 HTTPS-seose seadistused](./img/image12.png)

Peale määrangute kinnitamist ühepoolne SSL töötab!

![Ühepoolne SSL töötab TLS 1.3 protokolliga, veebilehitsejaks on Firefox!](./img/image13.png)

Ühepoolse SSL-i demonstreerimiseks kasutatud Firefox veebilehitseja näitab lisainfo akendes veel ka järgmist:

1.  Kasutusel on värskelt installeeritud sertifikaat `2111.kaheksa.xi`;
2.  Kasutusel on TLS 1.3 protokoll.

#### Serverisertifikaadi OCSP vastuse stapling

Kui serverisertifikaat sisaldab OCSP teenuse URI-d ja sertifikaadi väljastanud
CA toetab OCSP-d, jäta HTTPS-seose valik *Disable OCSP Stapling* märkimata.
HTTP.sys saab siis hankida serverisertifikaadi kohta allkirjastatud
olekuvastuse ja saata selle TLS kätluse ajal. Nii ei pea iga veebilehitseja
väljastanud CA-le eraldi päringut tegema ja kliendi privaatsus paraneb.[^8]

Kuva seos ja kontrolli, et OCSP stapling ei ole keelatud:

```bat
netsh http show sslcert 0.0.0.0:443
```

Vajadusel luba stapling olemasoleval seosel:

```bat
netsh http update sslcert ipport=0.0.0.0:443 disableocspstapling=disable
```

Ära luba stapling'ut, kui sertifikaadi väljastaja OCSP teenust ei paku.
Kontrolli tulemust OpenSSL-iga kliendist:

```bash
$ openssl s_client -connect iis2111.kaheksa.xi:443 \
    -servername iis2111.kaheksa.xi -status </dev/null
```

Väljundis peab olema edukas OCSP vastus ja sertifikaadi olek `good`. Monitoori
vastuse hankimise tõrkeid ning taga HTTP.sys-i ligipääs OCSP teenusele.

#### HTTP ligipääsu piiramine

HTTP ligipääsu keelamiseks eemaldatakse port 80 seotud protokollide loendist ja keelatakse tulemüürist ka vastav ligipääs. Alternatiivina on võimalik suunata HTTP liiklus automaatselt HTTPS saidile, vältimaks probleemi, kus kasutajad kirjutavad ise brauserisse saidi aadressi ent ei taipa sinna ette HTTPS:// määrangut panna.

## Kahepoolse SSL-i, sertifikaadiga autentimise nõudmine

### Eelhäälestus

> **Märkus:** TLS 1.3 koos *in-handshake* kliendisertifikaadi autentimisega
> on Windows Server 2025 soovituslik konfiguratsioon. HTTPS-seose
> seadistustes tuleb märkida *Negotiate Client Certificate*, et HTTP.sys
> küsiks kliendisertifikaati esialgse TLS kätluse ajal. Valikut
> *Disable TLS 1.3 over TCP* ei märgita. Microsoft kirjeldab Server 2025
> lahendust IIS Support Blogis[^3].

> **Ühilduvus:** Windows Server 2022 ei kuva IIS Manageris valikut
> *Negotiate Client Certificate*. Kui Server 2022 kasutamine peab jätkuma,
> tuleb kasutada allpool kirjeldatud
> [`netsh` protseduuri](#windows-server-2022-uhilduvus). Levinud
> veebilehitsejad ei toeta selle platvormi vaikimisi kasutatavat TLS 1.3
> *post-handshake* autentimist. TLS 1.3 võib keelata ja TLS 1.2 kasutada
> ainult dokumenteeritud erandina, kui rakendus peab küsima
> kliendisertifikaati pärast esialgse TLS ühenduse loomist ja rakenduse
> voogu ei ole võimalik muuta.

Järgmine Windows Server 2025 ekraanipilt näitab TLS 1.2 ühilduvuserandit.
Enne seose salvestamist vali serveri sertifikaat. See ei ole Windows Server
2025 soovituslik konfiguratsioon:

![TLS 1.2 ühilduvuserand: TLS 1.3 keelamine HTTPS-seose seadistustes](./img/image14.png)

### Eesti eID sertifikaatide häälestus IIS serveril

Kahepoolse SSL-i lubamiseks tuleb IIS serveri poolt nõuda sertifikaadiga autentimist. Vaikimisi lubab server enda poole pöördumisel kasutada kõiki sertifikaate, mis on tema poolt usaldatud ja millel on EKU-s kirjeldatud `client authentication` laiend. Korrektseks toimimiseks peab server suutma luua kogu sertifikaadiahela alates kasutajasertifikaadist kuni juursertifikaadini – see tähendab, et lisaks juurtaseme sertifikaatide olemasolule IIS serveris on vajalik ka kesktaseme (*intermediate*) sertifikaatide olemasolu.

IIS serveris tuleb sertifikaadid publitseerida järgmiselt:

1.  Usaldusväärsete juursertifikaatide konteinerisse:
    1.  `EE-GovCA2018` (<https://c.sk.ee/EE-GovCA2018.der.crt>)
    2.  `EEGovCA2025` (<https://crt.eidpki.ee/EEGovCA2025.crt>)
2.  Kesktaseme sertifikaatide konteinerisse[^4]:
    1.  `ESTEID2018` (<http://c.sk.ee/esteid2018.der.crt>)
    2.  `ESTEID2025` (<https://crt.eidpki.ee/ESTEID2025.crt>)

Veebisaidi SSL omaduste alt tuleb nõuda SSL protokolli ja kliendi sertifikaatide kasutamist:

![SSL ja sertifikaadi nõue](./img/image15.png)

Loodud konfiguratsioon lubab veebisaidile ligipääsu 443 pordi kaudu, kasutajalt nõutakse sertifikaati. Pöördudes veebisaidi poole lubatakse valida soovitav serveri poolt aktsepteeritud sertifikaat:

![Sertifikaadi küsimine veebisaidile pöördudes Firefox brauseris](./img/image16.png)

Peale PIN-i sisestamist kontrollitakse sertifikaadi kehtivust veebiserveri poolt ja kui kõik on korras, lastakse kasutaja veebisaidile ligi.

![TLS 1.2 ühilduvuserandi näide: autentimine õnnestus](./img/image17.png)

Enne soovitusliku TLS 1.3 konfiguratsiooni testimist tuleb lubada allpool
kirjeldatud *in-handshake* autentimine.

Alternatiivina võib IIS-i poolse sertifikaadinõude (`Require`) asemel kasutada ka lihtsat sertifikaadi aktsepteerimist (`Accept`) IIS serveri poolt – see võimaldab lisaks sertifikaadile saada serverile ligi ka kasutajanime ja parooliga või üldse autentimata.

### In-handshake autentimismeetodi lubamine

*In-handshake* autentimise korral küsib server kliendisertifikaati esialgse
TLS kätluse ajal. See on vajalik, sest TLS 1.3 ei toeta korduskätlust.

#### Windows Server 2025

1.  Vali IIS Manageris veebisait ja ava *Bindings*.
2.  Vali HTTPS-seos ja vajuta *Edit*.
3.  Märgi *Negotiate Client Certificate*.
4.  Jäta *Disable TLS 1.3 over TCP* märkimata ja salvesta seos.
5.  Vajadusel kontrolli käsuga `netsh http show sslcert`, et seose väärtus
    `Negotiate Client Certificate` on lubatud.

#### Windows Server 2022 ühilduvus {#windows-server-2022-uhilduvus}

Windows Server 2022 ei paku seose juures vastavat märkeruutu. Ainult sellel
vanemal platvormil tuleb kliendisertifikaadi läbirääkimine lubada käsuga
`netsh`:

1.  Kuva seose konfiguratsioon:

    ```bat
    netsh http show sslcert 0.0.0.0:443
    ```

    Salvesta räsi ja rakenduse ID. Enne muudatust sarnaneb oluline väljund
    järgmisega:

    ```text
    Certificate Hash             : <CERTIFICATE_HASH>
    Application ID               : {<APPLICATION_ID>}
    Negotiate Client Certificate : Disabled
    ```

2.  Eemalda sertifikaadi seotus 443 pordiga:

    ```bat
    netsh http del sslcert 0.0.0.0:443
    ```

    Käsu edukas väljund on `SSL Certificate successfully deleted`.

3.  Seo sertifikaat uuesti pordiga 443 ja luba *in-handshake*
    kliendisertifikaadiga autentimine:

    ```bat
    netsh http add sslcert ipport=0.0.0.0:443 ^
        certhash=<CERTIFICATE_HASH> ^
        appid={<APPLICATION_ID>} ^
        certstorename=MY ^
        clientcertnegotiation=Enable
    ```

    Asenda `CERTIFICATE_HASH` ja `APPLICATION_ID` 1. sammus saadud
    väärtustega. Käsu edukas väljund on `SSL Certificate successfully added`.

Käivita uuesti 1. sammu käsk `show sslcert`. Oluline väljund peab nüüd olema:

```text
Negotiate Client Certificate : Enabled
```

> **Märkus:** Kuna *session renegotiation* on `TLS 1.3` puhul keelatud, siis selle meetodi puhul tuleb arvestada asjaoluga, et autentimine peab toimuma „esimesel lehel". Kui ühepoolne SSL ühendus on juba kliendi sertifikaadiga autentimata loodud ja samal lehel soovitakse kliendi sertifikaadiga autentides mõnele kaitstud ressursile ligi pääseda, siis see ebaõnnestub, kuna `TLS 1.3` ei toeta sellist lähenemist. Vajadusel tuleb see „maandumise" probleem ühel või teisel viisil lahendada.

### Autentimine

Käesolevas näites on lubatud ainult anonüümne autentimine:

![Anonüümne autentimine, kasutaja saab saidile ligi kasutaja IUSR õigustes](./img/image22.png)

## Võimalikud lisakonfiguratsioonid

Selle dokumendi eesmärgiks ei ole anda täpseid juhiseid optimaalseks veebisaitide konfigureerimiseks ega turvamiseks. Pigem tutvustatakse siin konfiguratsiooni kahepoolse SSL-i kasutamiseks Eesti eID kaartidega. Siiski tuuakse järgnevalt välja punktid, mida on oluline mainida.

### Kasutajale kuvatavate sertifikaatide filtreerimine

Vaikimisi võib klient kuvada kõiki isiklikke sertifikaate, millel on privaatvõti
ja kliendi autentimise EKU. IIS saab saata lubatud sertimiskeskuste loendi, et
klient kuvaks toetatud ahelate sertifikaate.

Väljastajate loend parandab sertifikaadi valimist, kuid ei tõesta, et valitud
lõppsertifikaat on ID-kaardi autentimissertifikaat. Erinevad
sertifikaaditooted võivad kasutada sama juur- või kesktaseme CA-d. Enne
autenditud identiteedi aktsepteerimist tuleb rakendada järgmises jaotises
kirjeldatud sertifikaadipoliitika kontroll.

Seame eesmärgiks kuvada kasutaja pool vaid sertifikaadid, mis pärinevad kindla juurserveri `EE-GovCA2018` ja `EEGovCA2025` ahelast.

1.  Kuva aktiivse seose konfiguratsioon:

    ```bat
    netsh http show sslcert 0.0.0.0:443
    ```

    Salvesta räsi ja rakenduse ID. Enne muudatust sarnaneb oluline väljund
    järgmisega:

    ```text
    Certificate Hash : <CERTIFICATE_HASH>
    Application ID   : {<APPLICATION_ID>}
    Ctl Store Name   : (null)
    ```

2.  Eemalda sertifikaadi seos:

    ```bat
    netsh http del sslcert 0.0.0.0:443
    ```

    Käsu edukas väljund on `SSL Certificate successfully deleted`.

3.  Lisa sertifikaat uuesti ja kasuta lubatud sertimiskeskuste loendina
    sertifikaadihoidlat `Client Authentication Issuers`:

    ```bat
    netsh http add sslcert ipport=0.0.0.0:443 ^
        certhash=<CERTIFICATE_HASH> ^
        appid={<APPLICATION_ID>} ^
        sslctlstorename=ClientAuthIssuer
    ```

    Asenda `CERTIFICATE_HASH` ja `APPLICATION_ID` 1. sammus saadud
    väärtustega. Käsu edukas väljund on `SSL Certificate successfully added`.

4.  Käivita uuesti 1. sammu käsk `show sslcert` ja kontrolli olulist väljundit:

    ```text
    Ctl Store Name : ClientAuthIssuer
    ```

    Soovi korral on võimalik vaadata ka IIS-i konfiguratsioonist, et SSL sertifikaat on uuesti korrektselt seotud 443 pordiga.

5.  Lubatakse IIS serveri registrist sertifikaatide filtreerimine, lisades määrangu `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\SendTrustedIssuerList=1`:

    ![Sertifikaatide filtreerimise lubamine registris](./img/image26.png)

6.  Lisatakse SK kesktaseme sertifikaat IIS serveri sertifikaatide konteinerisse `Client Authentication Issuers`:

    ![Kliendi jaoks lubatud sertifikaatide lisamine õigesse konteinerisse](./img/image27.png)

7.  Vajadusel taaskäivitatakse IIS teenus või server ja kontrollitakse soovitud lahenduse toimimist!

### ID-kaardi sertifikaadipoliitika valideerimine

Enne autenditud identiteedi aktsepteerimist tuleb nõuda, et:

1.  HTTP.sys valideerib edukalt kogu sertifikaadiahela;
2.  väljastaja on selgesõnaliselt lubatud kesktaseme CA;
3.  `extendedKeyUsage` lubab TLS veebikliendi autentimist;
4.  lõppsertifikaadi laiendus `X509v3 CertificatePolicies` (`2.5.29.32`)
    sisaldab nii NCP+ autentimispoliitika OID-d kui ka sertifikaadi CA
    põlvkonnale vastavat lubatud dokumendipoliitika OID-d.[^9]

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

Sertifikaadihoidla `Client Authentication Issuers` ja EKU kontroll on
kasulikud lisakaitsed, kuid need ei tuvasta sertifikaaditoodet. IIS-i rakendus
või autentimislüüs peab valideeritud kliendisertifikaati kontrollima ja
autentimise tagasi lükkama, kui selles ei ole nii NCP+ OID-d kui ka
väljastajale vastavat dokumendipoliitika OID-d. Sertifikaaditoodet ei tohi
tuletada ainult subjekti, väljastaja või EKU järgi ning `anyPolicy` OID-d
(`2.5.29.32.0`) ei tohi käsitleda ID-kaardi poliitika tõendina.

Kasuta rakendusplatvormi kliendisertifikaadi API-t. .NET-i rakenduses valideeri
sertifikaat `X509ChainPolicy.CertificatePolicy` abil.[^10] Kontrolli iga
lubatud, väljastajaga seotud kombinatsiooni eraldi: nõua samas ahela
valideerimises NCP+ OID-d ja üht vastava CA põlvkonna lubatud
dokumendipoliitika OID-d. Dokumendipoliitika OID-d on alternatiivid; ära lisa
kõiki lubatud dokumendipoliitika OID-sid ühte valideerimisse samaaegselt
nõutavate poliitikatena.

HTTP päringu päises edastatud sertifikaati ei tohi usaldada, välja arvatud
juhul, kui usaldatud pöördproksi kirjutab päise üle ja rakendus on ligipääsetav
üksnes selle proksi kaudu.

Eksporditud sertifikaadi kontrollimiseks testi:

```bat
certutil -dump client.cer
```

Võrdle laiendust `Certificate Policies` eespool viidatud kehtivate poliitika-
ja sertifikaadiprofiilide allikatega. Testi vähemalt üht lubatud ID-kaardi
sertifikaati ja seotud hierarhiates väljastatud muude toodete sertifikaate,
sealhulgas vajaduse korral Mobiil-ID-d.

### Kliendisertifikaadi tühistusoleku kontroll OCSP abil

CA-de `ESTEID2018` ja `ESTEID2025` väljastatud sertifikaatides on AIA OCSP
teenuse aadress (<http://aia.sk.ee/esteid2018> ja
<http://ocsp.eidpki.ee>). HTTP.sys kasutab sertifikaadis avaldatud
tühistusinfo hankimiseks Windowsi sertifikaadiahela mootorit.

Kuva HTTPS-seos:

```bat
netsh http show sslcert 0.0.0.0:443
```

Kontrolli, et kliendisertifikaadi tühistusoleku ja kasutusotstarbe kontroll on
lubatud ning tühistusoleku kontroll ei piirdu ainult vahemällu salvestatud
andmetega. Vajadusel uuenda neid poliitikaid:[^8]

```bat
netsh http update sslcert ipport=0.0.0.0:443 ^
    verifyclientcertrevocation=enable ^
    verifyrevocationwithcachedclientcertonly=disable ^
    usagecheck=enable
```

Luba serverist väljuv liiklus tühistusinfo teenustesse, monitoori Windowsi
CAPI2 ja HTTP Service'i tõrkeid ning testi kehtiva ja tühistatud
sertifikaadiga. Määra ja testi rakenduse käitumine tühistusinfo ajutise
kättesaamatuse korral. Ära kasuta aegunud OCSP päringute arvu registripoliitikat
OCSP eelistamiseks CRL-ile; lase praegusel sertifikaadiahela mootoril kasutada
igas sertifikaadis avaldatud tühistusinfot.

### Soovituslikud IIS'i sätted

#### SSL/TLS

TLS protokollide valikul ei tohi tugineda IIS-i või Schanneli
vaikesätetele. TLS 1.0 ja TLS 1.1 tuleb keelata. Uutes ja ajakohastatud
lahendustes tuleb vaikimisi lubada ainult TLS 1.3.

TLS 1.2 võib lisada üksnes dokumenteeritud erandina, kui teenust peavad
kasutama 2020. aasta või vanemad kliendid või kui kliendisertifikaati
peab küsima pärast esialgse TLS ühenduse loomist. Sertifikaadiga
autentimine iseenesest ei ole põhjus TLS 1.2 lubamiseks. Windows Server
2025 puhul tuleb kasutada eespool kirjeldatud seose valikut
*Negotiate Client Certificate*.

Aruanne soovitab TLS 1.2 lubamisel korduskätluse keelata. Pärandlahendus, mis
küsib kliendisertifikaati alles pärast esialgset kätlust, ei saa samaaegselt
seda voogu säilitada ja soovitust järgida. Eelista eraldi seosel või
serverinimel kätluse ajal autentimist ning dokumenteeri allesjääv TLS 1.2
korduskätluse sõltuvus erandina.

Kui Schannel ja kasutatavad kliendid pakuvad tootmiskõlblikku tuge, eelista
hübriidrühma `X25519MLKEM768`. Juhend ei määra selle jaoks registri- ega
rühmapoliitika väärtust, sest tugi ja standarditud identifikaator sõltuvad
platvormist. Enne sellele tuginemist kontrolli läbiräägitud rühma ajakohase
TLS-skanneriga.

Rohkem infot TLS protokolli kasutamise soovituste kohta leiab RIA
tellitud krüptograafiliste algoritmide elutsükli uuringust aadressil
<https://www.id.ee/artikkel/kruptograafiliste-algoritmide-elutsukli-uuringud-2/>.

TLS protokollid tuleks hallata keskse poliitika või muu Windowsi
haldusvahendiga. Järgmisi registriväärtusi võib kasutada rakendatud
seadistuse kontrollimiseks või juhul, kui keskne haldusvahend ei ole
kasutatav. `TLS 1.0` ja `TLS 1.1` keelamiseks tuleb määrata[^5]:

- `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\`[^6]:
  - `TLS 1.0\Server`
    - `Enabled DWORD:0`
    - `DisabledByDefault = DWORD:1`
  - `TLS 1.1\Server`
    - `Enabled DWORD:0`
    - `DisabledByDefault = DWORD:1`

![TLS versioonide 1.0 ja 1.1 keelamine registris](./img/image30.png)

Ainult TLS 1.3 kasutava serveri jaoks võib samas asukohas keelata ka
`TLS 1.2\Server`, määrates `Enabled DWORD:0` ja
`DisabledByDefault DWORD:1`. See on kogu süsteemi Schanneli
serverirakendusi mõjutav muudatus, mistõttu tuleb enne rakendamist
kontrollida teisi teenuseid ja pärast muudatust need taaskäivitada.
Dokumenteeritud TLS 1.2 ühilduvuserandi korral TLS 1.2 ei keelata.

##### Pakkimine

Hoia TLS-i pakkimine keelatuna. HTTP pakkimine on IIS-is eraldiseisev
funktsioon: keela dünaamilise sisu pakkimine rakendustes, mille vastused
sisaldavad koos ründaja juhitavat sisendit ja saladusi. Kui HTTP vastuste
pakkimine peab jääma lubatuks, peab rakendus takistama saitidevahelist
päringuvõltsimist ning leevendama vastuse pikkuse leket. Kontrolli TLS-i
tulemust ajakohase skanneriga, sest IIS ei paku TLS-i pakkimiseks tavapärast
saiditaseme seadistust.

#### Šifrikomplektid (Cipher suites)

Konfigureeri selge lubatud loend keskse poliitika või Windowsi TLS
PowerShelli käskude abil. Esmalt kontrolli paigaldatud operatsioonisüsteemi
toetatud komplekte käsuga `Get-TlsCipherSuite`[^7].

Windows Server 2025 soovitusliku, ainult TLS 1.3 kasutava profiili jaoks
luba järgmised komplektid toodud järjekorras. Schannel toetab kõiki kolme;
ChaCha20-Poly1305 on toetatud, kuid ei ole vaikimisi lubatud:

```text
TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_AES_128_GCM_SHA256
```

Dokumenteeritud TLS 1.2 ühilduvuserandi korral lisa Windows Server 2025
toetatud kaks ECDSA TLS 1.2 komplekti. See vastab juhendis kasutatavale ainult
ECDSA sertifikaadi profiilile:

```text
TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
```

Aruanne lubab TLS 1.2 puhul ka ECDHE-ECDSA komplekti šifriga
ChaCha20-Poly1305, kuid Windows Server 2025 Schannel seda ei paku. Aruanne
lubab ka RSA-ga autenditud komplekte, kuid see ainult ECDSA profiil jätab need
välja. `TLS_AES_128_CCM_SHA256` on ainult varuvariant juhuks, kui AES-GCM ja
ChaCha20-Poly1305 ei ole saadaval, ning ei kuulu sellesse Windows Serveri
profiili. RSA autentimist ega võtmevahetust, DHE varuvarianti, CBC-d, CCM_8-t
ega muid mitte-AEAD komplekte ei tohi lubada.

Sisesta sobiv komadega eraldatud lubatud loend määrangusse *SSL Cipher Suite
Order*. Poliitika asub:

- kohalikus rühmapoliitika redaktoris: *Computer Configuration* →
  *Administrative Templates* → *Network* → *SSL Configuration Settings* →
  *SSL Cipher Suite Order*;
- domeeni rühmapoliitika halduses: *Computer Configuration* → *Policies* →
  *Administrative Templates* → *Network* → *SSL Configuration Settings* →
  *SSL Cipher Suite Order*.

Poliitika väärtus `Functions` talletatakse registris:

```text
HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002
```

Pärast poliitika rakendamist kuva tegelikud šifrikomplektid tähtsuse
järjekorras:

```powershell
Get-TlsCipherSuite
```

Käsk kuvab iga komplekti eraldi kirjena; komplekti nimi on väljal `Name`.
Poliitikaga määratud toorväärtuse kontrollimiseks käivita:

```powershell
Get-ItemPropertyValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' `
    -Name Functions
```

##### Muud konfigureeritavad Schannel omadused

Muud Schanneli seadistused asuvad registris:

```text
HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL
```

Loo ainult paigaldatud Windows Serveri versiooni jaoks dokumenteeritud
väärtusi. Algoritmi nime olemasolu registris ei näita iseenesest, kas
algoritm on lubatud või kasutusel.

#### Muud võimalused

Lisaks TLS-i ja šifrikomplektide konfigureerimisele, on palju muudki võimalik ära teha IIS-i serveri turvamiseks:

- Hoida operatsioonisüsteem ajakohasena.
- Keelata serveri info presenteerimine.
- Keelata HTTP päringud.
- Keelata failide lappamise võimalus (*directory listing*).
- Kasutada mitte-süsteemseid ja mitte-administraator kontosid.
- Lubada HSTS.
- …

Palume suhtuda ülaltoodusse kui näidisloendisse demonstreerimaks, mida veel saab IIS'i turvalisemaks muutmise jaoks ära teha. Põhjalikemaid soovitusi on võimalik leida paljudelt internetilehtedelt:

<https://www.google.com/search?q=how+to+secure+IIS+server>

[^1]: <https://www.id.ee/artikkel/paigalda-id-tarkvara/>

[^2]: Juhul, kui sertifikaadi on väljastanud mõni kesktaseme CA, siis tuleb
    see puudumisel lisada *kesktaseme sertimiskeskuste* konteinerisse. Ja
    kesktaseme CA sertifikaadi väljastanud juur-CA sertifikaat tuleb
    puudumisel lisada *usaldusväärsete juursertifikaatide* konteinerisse.

[^3]: <https://techcommunity.microsoft.com/blog/iis-support-blog/addressing-tls-1-3-compatibility-issues-in-iis-express-on-windows-11/4449362/>

[^4]: SK poolt väljastatud organisatsioonide kaartide kasutuse puhul peavad
    kesktaseme sertifikaatide hulka olema häälestatud ka `EID-SK 2016`
    (<https://www.sk.ee/upload/files/EID-SK_2016.der.crt>) sertifikaadid!

[^5]: Vaikimisi neid väärtuseid ei eksisteeri.

[^6]: Võimalik on konfigureerida eraldi ka kliendi osa SSL/TLS protokollide
    vaates. Käesolev juhend käsitleb ainult serveri poole häälestust. See ei
    tähenda, et kliendi osa konfigureerimine ei ole soovitatav, see sõltub
    alati konkreetsest situatsioonist.

[^7]: <https://learn.microsoft.com/en-us/windows/win32/secauthn/tls-cipher-suites-in-windows-server-2025>

[^8]: <https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-http>

[^9]: Lubatud loend põhineb
    [ESTEID2018 sertifitseerimispoliitikal v4.0](https://www.id.ee/wp-content/uploads/2025/10/cp_esteid_v4.0-08.10.2025.pdf),
    [ESTEID2025 sertifitseerimispoliitikal v2.0](https://repository.eidpki.ee/static/documents/eid-cp-v-2.0_04.06.2026_allkirjastatud.pdf)
    ja [Zetesi sertifikaadiprofiilidel](https://repository.eidpki.ee/static/documents/CertificateProfiles-20260520.pdf).
    Enne tootmise lubatud loendi muutmist kontrolli
    [Zetesi repositooriumi](https://repository.eidpki.ee/repository/) ning
    teenuseosutajate kehtivaid poliitikaid ja profiile.

[^10]: <https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509chainpolicy.certificatepolicy?view=net-9.0>
