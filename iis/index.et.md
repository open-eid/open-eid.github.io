# IIS veebiserverile ID-kaardi toe seadistamine

**[In English](index.md)**

**Versioon:** 26.04/1

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

Juhend, kuidas autentida kasutajat IIS veebiserveril Eesti eID kaartidega.

---

- TOC
{:toc}

## Sissejuhatus

Käesolevas juhendis kirjeldame IIS veebiserveri konfiguratsiooni kahepoolse SSL-i kasutamiseks, kus kliendi poolseks sertifikaadiks on Eesti eID kaardile (ID-kaart, elamisloakaart, digi-ID ja e-residendi digi-ID) väljastatud sertifikaat.

Juhendi loomisel on kasutatud Windows Server 2022 ja Windows 10 operatsioonisüsteeme. Näidisjuhendis on toetatud [SK ID Solutions](https://www.skidsolutions.eu/resources/certificates/) `EE-GovCA2018` ja [Zetes](https://repository.eidpki.ee/) `EEGovCA2025` ahelast pärinevad sertifikaadid. Tagamaks sertifikaatide äratundmist on kohustuslikuks komponendiks kliendi poolel ka ID-tarkvara[^1]. Näidisjuhendi serveri sertifikaat on väljastatud OctoX testkeskkonnast.

IIS kasutamisel on võimalik rakendada erinevaid autentimismeetodeid. Käesolev dokument vaatleb sertifikaadi nõude kehtestamist IIS anonüümse autentimise jaoks – st. peale sertifikaadi kehtivuse kontrolli lubatakse kasutaja eelnevalt määratud kasutaja (IUSR) õigustes veebisaidile ligi.

Hetkel on testid edukalt läbi viidud järgmiste brauseritega (viimased versioonid):

1.  Microsoft Edge
2.  Mozilla Firefox
3.  Google Chrome

## Ühepoolse SSL/TLS-i konfigureerimine

### Windows serveri sertifikaadi konfiguratsioon

Pakkumaks turvalist veebiteenust peab IIS serverile olema määratud TLS sertifikaat - meie näites on kasutusel OctoX testkeskkonnast väljastatud sertifikaat. Samuti peavad nii kliendid kui ka veebiserver ise usaldama nimetatud sertifikaati.

Domeeni keskkonnas ja domeeni (*enterprise*) CA olemasolul on tõenäoliselt kõige mõistlikum küsida ka serveri sertifikaat domeeni CA-lt. Ent juhul, kui meid ei rahulda domeeni taseme turvalisus ja võimalused või kui vajame sertifikaati, mis on laiemalt usaldatud, tuleb luua privaatvõti ning sertifikaadi päring ja lasta viimase alusel luua sertifikaat mõnel üldtuntud CA-l.

#### Serveri sertifikaadi hankimine

Kuna IIS halduskonsoolilt loodav sertifikaadi päring on üsna piiratud võimalustega, kasutame serveri sertifikaadi loomiseks hoopis sertifikaatide halduskonsooli. Käivitame IIS serveril `mmc.exe` ja lisame sinna lokaalse arvuti sertifikaadid. Loome kohandatud päringu:

![Alustame kohandatud päringu loomisega](./img/image1.png)

Klikime kolm korda *Next* ja valime *Details, Properties.* Avaneb sertifikaadi päringu omaduste aken:

![Sertifikaadi päringu omaduste aken](./img/image2.png)

Järgnevalt saame määrata päringufailile täpsed omadused, milliseid tahame hiljem oma veebiserveri sertifikaadi juures näha.

Juhul, kui meil on tarvis sarnaseid päringufaile tihedamini luua, soovitame tegevuse automatiseerimiseks tutvuda `PowerShell` võimalustega.

##### Sakk General

Siin määrame soovi korral sertifikaadi hüüdnime ja põgusa kirjelduse. Need väljad ei ole sertifikaadi sisulised osad ja omavad tähendust selgituse, hilisema lihtsama arusaama mõttes.

![Sertifikaadi üldinfo](./img/image3.png)

##### Sakk Subject

Aknas *Subject* kirjeldame subjekti nagu ikka. Kui soovime kasutada erinevaid SAN DNS nimesid või kasutame *common name* puhul midagi muud kui FQDN, siis tuleb üks või mitu DNS aliast siin ka kirjeldada.

![Subjekti näidiskonfiguratsioon](./img/image4.png)

##### Sakk Extensions

Aknas *Extensions* määrame järgmised omadused:

1.  Key Usage:
    1.  Digital signature;
    2.  Key encipherment.
2.  Extended Key Usage:
    1.  Server Authentication.

![Laienduste määramine](./img/image5.png)

##### Sakk Private Key

Siit aknast valime CSP ehk sertifikaadi võtmete algoritmi. Näidis-konfiguratsioonis kasutame algoritmi `ECDSA_P256`, seega valime loendist `ECDSA_P256` ja eemaldame nimekirja alguses oleva RSA.

![CSP valimine](./img/image6.png)

Klikime *OK* ja *Next*, määrame kausta ning nime ja salvestame sertifikaadi päringu `Base64` formaadis.

Võime värskelt loodud sertifikaadi päringufaili omadused kontrollida üle käsuga `certutil -dump PÄRINGUFAILI_NIMI`.

![Päringufaili sisu](./img/image7.png)

Veendume, et ka DNS alternatiivsed nimed on päringufailis olemas:

![DNS aliased päringufailis](./img/image8.png)

Nüüd edastame sertifikaadi päringufaili mõnele CA serverile ja palume selle alusel endale sertifikaadi genereerida. Tulemus on järgmine:

![IIS serveri sertifikaat](./img/image9.png)

#### Sertifikaadi installeerimine

IIS server peab usaldama sertifikaati `OctoX Demo CA 21.11`, mis on serveri sertifikaadi väljastajaks. Selleks peame kontrollima selle sertifikaadi olemasolu *usaldusväärsete juursertifikaatide*[^2] konteineris. Kui väljastaja CA sertifikaat sealt puudub, tuleb see lisada![^3]

![IIS server usaldab temale sertifikaadi väljastanud CA-d.](./img/image10.png)

IIS serveri sertifikaat ise tuleb paigaldada IIS serveril lokaalse arvuti personaalsesse konteinerisse:

![Avades sertifikaadi näeme, et IIS serveril on ka selle privaatvõti kasutada!](./img/image11.png)

### Ühepoolse SSL-konfiguratsiooni loomine

Ühepoolse SSL-i kehtestamiseks peab veebisaidil olema kirjeldatud SSL port (vaikimisi 443) ja see peab olema seotud soovitava sertifikaadiga. Koheselt keelame ka vanade SSL/TLS protokollide (vanemad kui 1.2) kasutamise!

![Veebisaidil on lubatud 443 port ja kasutatavaks sertifikaadiks on iis2111.kaheksa.xi, vanad TLS protokollid tuleb keelata!](./img/image12.png)

Peale määrangute kinnitamist ühepoolne SSL töötab!

![Ühepoolne SSL töötab TLS 1.3 protokolliga, veebilehitsejaks on Firefox!](./img/image13.png)

Ühepoolse SSL-i demonstreerimiseks kasutatud Firefox veebilehitseja näitab lisainfo akendes meile veel ka järgmist:

1.  Kasutusel on meie värskelt installeeritud sertifikaat `2111.kaheksa.xi`;
2.  Kasutusel on TLS 1.3 protokoll.

#### HTTP ligipääsu piiramine

HTTP ligipääsu keelamiseks eemaldame pordi 80 seotud protokollide loendist ja keelame tulemüürist ka vastava ligipääsu. Alternatiivina võime suunata HTTP liikluse automaatselt HTTPS saidile vältimaks probleemi, kus kasutajad kirjutavad ise brauserisse saidi aadressi ent ei taipa sinna ette HTTPS:// määrangut panna.

## Kahepoolse SSL-i, sertifikaadiga autentimise nõudmine

### Eelhäälestus

> **Märkus:** IIS 10/Schannel, mis töötab Windows Server 2022 platvormil, kasutab sertifikaadiga autentimiseks protokolli `TLS 1.3` abil vaikimisi post-handshake autentimismeetodit (kehtib alates 2022. aastast, aktuaalne ka 2026. aastal). Kuna aga enimlevinud brauserid seda ei toeta[^4], siis see lahendus paraku praktikas ei tööta! Juhul, kui `TLS 1.3` on sisse lülitatud, ei saada server kliendile vaikimisi konfiguratsioonis sertifikaadi päringut ja katkestab ühenduse! Sertifikaadiga autentimise tööle saamiseks tuleb keelata `TLS 1.3` kasutamine. Alternatiivina saame sisse lülitada in-handshake autentimismeetodi, vt. peatükk „[In-handshake autentimismeetodi lubamine](#in-handshake-autentimismeetodi-lubamine)".

> **Märkus:** Windows Server 2025 platvormil on see probleem lahendatud — IIS lisab HTTPS-seose seadistustesse „Negotiate Client Certificate" märkeruudu, mis võimaldab in-handshake autentimist otse liidesest ilma allpool kirjeldatud `netsh` käsuta.

`TLS 1.3` protokolli versiooni saame välja lülitada IIS HTTPS seose lehelt, märkides linnukese lahtrisse `Disable TLS 1.3 over TCP`:

![Sertifikaadiga autentimise lubamiseks peame paraku TLS 1.3 protokolli keelama](./img/image14.png)

### Eesti eID sertifikaatide häälestus IIS serveril

Kahepoolse SSL-i lubamiseks tuleb IIS serveri poolt nõuda sertifikaadiga autentimist. Vaikimisi lubab server enda poole pöördumisel kasutada kõiki sertifikaate, mis on tema poolt usaldatud ja millel on EKU-s kirjeldatud `client authentication` laiend. Korrektseks toimimiseks peab server suutma luua kogu sertifikaadiahela alates kasutajasertifikaadist kuni juursertifikaadini – see tähendab, et lisaks juurtaseme sertifikaatide olemasolule IIS serveris on vajalik ka kesktaseme (*intermediate*) sertifikaatide olemasolu.

Meie konfiguratsiooni puhul tuleb IIS serveris sertifikaadid publitseerida järgmiselt:

1.  Usaldusväärsete juursertifikaatide konteinerisse:
    1.  `EE-GovCA2018` (<https://c.sk.ee/EE-GovCA2018.der.crt>)
    2.  `EEGovCA2025` (<https://crt.eidpki.ee/EEGovCA2025.crt>)
2.  Kesktaseme sertifikaatide konteinerisse[^5]:
    1.  `ESTEID2018` (<http://c.sk.ee/esteid2018.der.crt>)
    2.  `ESTEID2025` (<https://crt.eidpki.ee/ESTEID2025.crt>)

Veebisaidi SSL omaduste alt tuleb nõuda SSL protokolli ja kliendi sertifikaatide kasutamist:

![SSL ja sertifikaadi nõue](./img/image15.png)

Loodud konfiguratsioon lubab veebisaidile ligipääsu 443 pordi kaudu, kasutajalt nõutakse sertifikaati. Pöördudes veebisaidi poole lubatakse valida soovitav serveri poolt aktsepteeritud sertifikaat:

![Sertifikaadi küsimine veebisaidile pöördudes Firefox brauseris](./img/image16.png)

Peale PIN-i sisestamist kontrollitakse sertifikaadi kehtivust veebiserveri poolt ja kui kõik on korras, lastakse kasutaja veebisaidile ligi.

![Autentimine õnnestus kasutades protokolli TLS 1.2](./img/image17.png)

Alternatiivina võib IIS-i poolse sertifikaadinõude (`Require`) asemel kasutada ka lihtsat sertifikaadi aktsepteerimist (`Accept`) IIS serveri poolt – see võimaldab lisaks sertifikaadile saada serverile ligi ka kasutajanime ja parooliga või üldse autentimata.

### In-handshake autentimismeetodi lubamine

Kui soovime siiski kasutada `TLS 1.3` protokolli ja kasutada sertifikaadiga autentimist, saame lubada in-handshake autentimismeetodi. Selle meetodi puhul küsib server kliendilt *Server Hello* saatmisel koheselt ka sertifikaati.

In-handshake autentimismeetodi lubamiseks tuleb teha järgmist:

1.  Dokumenteerida olemasoleva sertifikaadi määrangud käsuga `netsh http show sslcert`. Oluline on üles märkida `Certificate Hash` ja `Application ID`:

    ![Vaikimisi on määrang "negotiate client certificate" keelatud](./img/image18.png)

2.  Eemaldame sertifikaadi seotuse 443 pordiga käsuga `netsh http del sslcert 0.0.0.0:443`:

    ![Sertifikaadi eemaldamine 443 pordi küljest.](./img/image19.png)

3.  Ja lisame selle uuesti lubades ühtlasi ka in-handshake autentimismeetodi käsuga `netsh http add sslcert ipport=0.0.0.0:443 certhash=312bbb70898b5ae10753998c67bceeeb97d49f79 appid={4dc3e181-e14b-4a21-b022-59fc669b0914} certstorename=MY clientcertnegotiation=Enable`:

    ![Clientcertnegotiation lubamine](./img/image20.png)

Vaadates uuesti sertifikaadi infot näeme, et `Negotiate Client Certificate` on nüüd lubatud:

![In-handshake autentimismeetod on nüüd sees](./img/image21.png)

> **Märkus:** Kuna *session renegotiation* on `TLS 1.3` puhul keelatud, siis selle meetodi puhul tuleb arvestada asjaoluga, et autentimine peab toimuma „esimesel lehel". Kui oleme juba kliendi sertifikaadiga autentimata ühepoolse SSL ühenduse loonud ja samal lehel soovime kliendi sertifikaadiga autentides mõnele kaitstud ressursile ligi pääseda, siis me ebaõnnestume, kuna `TLS 1.3` ei toeta sellist lähenemist. Vajadusel tuleb see „maandumise" probleem ühel või teisel viisil lahendada.

### Autentimine

Meie näites on lubatud ainult anonüümne autentimine:

![Anonüümne autentimine, kasutaja saab saidile ligi kasutaja IUSR õigustes](./img/image22.png)

## Võimalikud lisakonfiguratsioonid

Selle dokumendi eesmärgiks ei ole anda täpseid juhiseid optimaalseks veebisaitide konfigureerimiseks ega turvamiseks. Pigem tahame tutvustada konfiguratsiooni kahepoolse SSL-i kasutamiseks Eesti eID kaartidega. Siiski toome järgnevalt välja punktid, mida peame oluliseks mainida.

### Kasutajapoolsete sertifikaatide filtreerimine

Vaikimisi pakutakse kasutajapoolse kahepoolse SSL sessiooni alustamisel IIS puhul kliendile välja kõik sertifikaadid, millistel on EKU omaduste all kirjas kliendi autentimine (ja loomulikult peab olema ka sertifikaadi privaatvõti). IIS-i poolt on aga kliendile võimalik ette anda loend autentimiskeskustest millised on lubatud ja seeläbi kuvatakse edaspidi klientidele vaid toetatud ahelate sertifikaadid.

Seame eesmärgiks kuvada kasutaja pool vaid sertifikaadid, mis pärinevad kindla juurserveri `EE-GovCA2018` ja `EEGovCA2025` ahelast.

1.  Kuvame aktiivse IIS sertifikaadi info käsuga `netsh http show sslcert 0.0.0.0:443`:

    ![Vaikimisi seotud sertifikaadi omadused](./img/image23.png)

2.  Eemaldame selle sertifikaadi seose käsuga `netsh http del sslcert 0.0.0.0:443`:

    ![Sertifikaadi eemaldamine](./img/image19.png)

3.  Lisame sertifikaadi uuesti ja ütleme, et sertifikaatide filtreerimiseks kasutame arvuti sertifikaatide kausta `Client Authentication Issuers`. Käsuks on `netsh http add sslcert ipport=0.0.0.0:443 certhash=1e75c77c696aa4d49686bb1ef73ac3b07fdff38a appid={4dc3e181-e14b-4a21-b022-59fc669b0914} sslctlstorename=ClientAuthIssuer`:

    ![Lisame sertifikaadi uute omadustega](./img/image24.png)

    `Certhash` ja `appid` väärtused saame 1. sammu väljundist ülal.

4.  Kontrollime, et `CTL Store Name` on uuel sertifikaadi väljavõttel `ClientAuthIssuer`:

    ![Uuesti seotud sertifikaadi omadused](./img/image25.png)

    Näeme soovi korral ka IIS-i konfiguratsioonist, et SSL sertifikaat on uuesti korrektselt seotud 443 pordiga.

5.  Lubame IIS serveri registrist sertifikaatide filtreerimise lisades määrangu `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\SendTrustedIssuerList=1`:

    ![Sertifikaatide filtreerimise lubamine registris](./img/image26.png)

6.  Lisame SK kesktaseme sertifikaadi IIS serveri sertifikaatide konteinerisse `Client Authentication Issuers`:

    ![Kliendi jaoks lubatud sertifikaatide lisamine õigesse konteinerisse](./img/image27.png)

7.  Vajadusel taaskäivitame IIS teenuse või serveri ja kontrollime soovitud lahenduse toimimist!

### Kliendisertifikaatide kehtivuse kontroll OCSP teenuse vastu

OCSP teenuse abil saame kasutaja sertifikaadi kehtivust kontrollida praktiliselt reaalajas. Iga kasutaja autentimisel saadab veebiserver päringu OCSP teenusele, mis tagastab sertifikaadi kehtivuse info.

`ESTEID2018` ja `ESTEID2025` CA alt väljastatud sertifikaatide puhul on AIA OCSP aadress juba sertifikaadis kirjas (<http://aia.sk.ee/esteid2018> ja <http://ocsp.eidpki.ee>), nii et siin me tegelikult midagi eraldi konfigureerima ei pea. Küll aga saame soovi korral kehtestada ka keskelt AIA OCSP kontrolli:

![AIA OCSP tee konfigureerimine](./img/image28.png)

> **Märkus:** Kordan siin selguse mõttes, et `ESTEID2018` / `ESTEID2025` CA alt väljastatud sertifikaatidel on kehtivuskontrollina kasutusel AIA OCSP teenus aadressiga <http://aia.sk.ee/esteid2018>. CRL teed neis kirjeldatud ei ole.

> **Märkus:** Windows serveri puhul pöördutakse vaikimisi OCSP põhiselt sertifikaatide kehtivuse kontrollilt tagasi CRL põhisele kontrollile, kui vahemälus olevate OCSP päringute hulk ületab 50-ne piiri. Meie konfiguratsiooni puhul ei ole see tegelikult oluline, kuna CRL-i me üldse ei kasuta. Muude konfiguratsioonide puhuks mainin, et seda numbrit on võimalik muuta luues registri väärtuse `HKEY_LOCAL_MACHINE/Software/Policies/Microsoft/SystemCertificates/ChainEngine/Config/CryptnetCachedOcspSwitchToCrlCount` ja määrates sinna uue väärtuse. Vt. ka OCSP [*magic count*](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/ee619754(v=ws.10)#determining-preference-between-ocsp-and-crls) või *magic number*. Ehk aga lihtsamgi tee selle omaduse muutmiseks on *windows policy*:

![Maagilise OCSP numbri muutmine](./img/image29.png)

### Soovituslikud IIS'i sätted

#### SSL/TLS

IIS'i versioon 10 serveril 2022 kasutab vaikimisi kõiki TLS protokollide versioone, 1.0–1.3[^6]. Vanemad SSL protokollid ei ole vaikimisi kasutusel.

Tänapäeval ei tohiks kindlasti enam kasutada `TLS 1.0` ja `TLS 1.1`. Kahepoolse autentimise toimimiseks peab olema lubatud `TLS 1.2` ja loodetavasti ajutiselt keelatud `TLS 1.3` (loe täpsemalt peatükist „Kahepoolse SSL-i, sertifikaadiga autentimise nõudmine – Eelhäälestus"). Kui sertifikaadiga autentimine ei ole oluline, võib hea mõte olla lubada vaid `TLS 1.3`.

Rohkem infot TLS protokolli kasutamise soovituste kohta leiab RIA tellitud krüptograafiliste algoritmide elutsükli uuringust aadressil <https://www.id.ee/artikkel/kruptograafiliste-algoritmide-elutsukli-uuringud-2/>.

Lisaks IIS konfiguratsiooni juures vanade TLS protokollide keelamisele saame seda teha ka otse registris. Kui me soovime keelata `TLS 1.0` ja `TLS 1.1`, tuleb meil lisada registrisse järgmine konfiguratsioon[^7]:

- `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\`[^8]:
  - `TLS 1.0\Server`
    - `Enabled DWORD:0`
    - `DisabledByDefault = DWORD:1`
  - `TLS 1.1\Server`
    - `Enabled DWORD:0`
    - `DisabledByDefault = DWORD:1`

![TLS versioonide 1.0 ja 1.1 keelamine registris](./img/image30.png)

Ja muidugi on võimalik ülaltoodud registri konfiguratsiooni levitada ka kesksete poliitikate abil.

#### Šifrikomplektid (Cipher suites)

Windows serveriga tuleb vaikimisi kaasa mitmeid šifrikomplekte. Kõiki neid saame vaadata näiteks `PowerShell` käsuga `Get-TLSCipherSuite`[^9].

Kindlat soovitust erinevate šifrikomplektide kasutamiseks ei ole veebisaidile esitatavaid tingimusi teadmata võimalik anda. Küll aga tundub mõistlik eemaldada loendist ebaturvalised šifrikomplektid (juhul, kui neid seal on). Enne konfiguratsiooniga jätkamist soovitame kindlasti tutvuda RIA tellitud krüptograafiliste algoritmide elutsükli uuringu soovitustega aadressil <https://www.id.ee/artikkel/kruptograafiliste-algoritmide-elutsukli-uuringud-2/>. Mõistlik võib olla konkreetsete šifrikomplektide lubamine.

Seega, kui soovime ise täpsemalt määrata kasutatavaid šifrikomplekte, on ilmselt parim selleks kasutada kohalikke või keskseid poliitikaid. Kasutamaks ainult šifrikomplekte `ECDHE-ECDSA-AES256-GCM-SHA384` ja `ECDHE-RSA-AES256-GCM-SHA384`, tuleb meil modifitseerida määrangut `Computer Configuration/Administrative Templates/Network/SSL Configuration Settings: SSL Cipher Suite Order`. Šifrikomplektid tuleb eraldada komaga.[^10]

![Kindlate šifrikomplektide määramine keskse poliitikaga](./img/image31.png)

Eelmises punktis määratud konfiguratsioon kirjutatakse registrisse:

![Poliitikaga määratud konfiguratsioon](./img/image32.png)

Vaikimisi on šifrikomplektid kirjeldatud järgmisel pildil kirjeldatud asukohas:

![Vaikimisi šifrikomplektide konfiguratsioon](./img/image33.png)

##### Muud konfigureeritavad Schannel omadused

Vaikimisi asukoht Schanneli konfigureeritavatele omadustele on registris: `HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL`. Siin on võimalik erinevaid komponente lubada või keelata, kirjutada vajadusel üle vaikimisi konfiguratsiooni määranguid.

![Schannel konfigureeritavad omadused](./img/image34.png)

#### Muud võimalused

Lisaks TLS-i ja šifrikomplektide konfigureerimisele, saame palju muudki ära teha oma IIS-i serveri turvamiseks:

- Hoiame operatsioonisüsteemi ajakohasena.
- Keelame serveri info presenteerimise.
- Keelame HTTP päringud.
- Keelame failide lappamise võimaluse (*directory listing*).
- Kasutame mitte-süsteemseid ja mitte-administraator kontosid.
- Lubame HSTS'i.
- …

Palume suhtuda ülaltoodusse kui näidisloendisse demonstreerimaks, mida veel saab IIS'i turvalisemaks muutmise jaoks ära teha. Põhjalikemaid soovitusi on võimalik leida paljudelt internetilehtedelt:

<https://www.google.com/search?q=how+to+secure+IIS+server>

[^1]: <https://www.id.ee/artikkel/paigalda-id-tarkvara/>

[^2]: Trusted root certification authorities

[^3]: Juhul, kui sertifikaadi on väljastanud mõni kesktaseme CA, siis tuleb see puudumisel lisada *kesktaseme sertimiskeskuste* konteinerisse. Ja kesktaseme CA sertifikaadi väljastanud juur-CA sertifikaat tuleb puudumisel lisada *usaldusväärsete juursertifikaatide* konteinerisse.

[^4]: Firefox teadaolevalt toetab, ent ka sellel brauseril ei ole see vaikimisi lubatud.

[^5]: SK poolt väljastatud organisatsioonide kaartide kasutuse puhul peavad kesktaseme sertifikaatide hulka olema häälestatud ka `EID-SK 2016` (<https://www.sk.ee/upload/files/EID-SK_2016.der.crt>) sertifikaadid!

[^6]: <https://docs.microsoft.com/en-us/windows/win32/secauthn/protocols-in-tls-ssl--schannel-ssp-?redirectedfrom=MSDN>

[^7]: Vaikimisi neid väärtuseid ei eksisteeri.

[^8]: Võimalik on konfigureerida eraldi ka kliendi osa SSL/TLS protokollide vaates. Hetkel aga räägime ainult serveri poole häälestusest. See ei tähenda, et kliendi osa konfigureerimine ei ole soovitatav, see sõltub alati konkreetsest situatsioonist.

[^9]: <https://docs.microsoft.com/en-us/windows/win32/secauthn/cipher-suites-in-schannel>

[^10]: Märgime siinkohal, et nende konkreetsete määrangutega `TLS 1.3` ei toimi! Pigem võib nende määrangute kasutamine olla mõttekas juhul, kui me ei soovi `TLS 1.3`-e kasutada, kasvõi näiteks sertifikaadiga autentimise lubamise puhul.
