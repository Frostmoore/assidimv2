import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Assidim/assets/constants.dart' as constants;
import 'package:Assidim/core/models/app_config.dart';

class Liberatoria extends StatefulWidget {
  final AppConfig config;
  const Liberatoria({super.key, required this.config});

  @override
  State<Liberatoria> createState() => _LiberatoriaState();
}

class _LiberatoriaState extends State<Liberatoria> {
  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    String nomeAgenzia = c.nomeAgenzia;
    String indirizzoAgenzia = c.sedi.isNotEmpty
        ? c.sedi[0].indirizzo.replaceAll('/n', ' ')
        : '';
    String emailAgenzia = c.sedi.isNotEmpty ? c.sedi[0].email : '';

    String capitolo1 =
        "<p style='text-align:justify;'>Ai sensi degli artt. 13 e 14 del GDPR 679/2016 – Regolamento europeo sulla protezione dei dati personali e in relazione ai dati personali che La riguardano e che formeranno oggetto del trattamento, La informiamo che:<br>Qualora in intestazione siano riportati dati di una persona giuridica, i dati oggetto della presente saranno quelli riferiti alle persone fisiche operanti nella stessa, di cui <strong>$nomeAgenzia</strong>  verrà a conoscenza.<br><strong>$nomeAgenzia</strong> in qualità di Titolare del trattamento intende acquisire, anche verbalmente, direttamente o tramite terzi, o già detiene, alcuni Suoi dati, qualificati come personali, il cui trattamento viene effettuato nel rispetto dei diritti e delle libertà fondamentali, nonché della dignità dell’interessato, con particolare riferimento alla riservatezza, all’identità personale, al diritto ed alla protezione dei dati personali.<br>Saranno inoltre trattate anche categorie particolari di dati, che devono essere forniti da Lei in qualità di soggetto interessato o da terzi, ad esempio da contraenti di polizze collettive o individuali che La qualificano come assicurato, beneficiario, proprietario dei beni assicurati o danneggiato (come nel caso di polizze di responsabilità civile) oppure da banche dati che vengono consultate in fase pre assuntiva, assuntiva o liquidativa.<br>Ciò premesso, <strong>$nomeAgenzia</strong>  La informa riguardo le finalità e le modalità del trattamento dei dati personali raccolti e il loro ambito di comunicazione e diffusione, oltre alla natura del loro conferimento, premettendo che i trattamenti avvengono nel contesto delle analisi obbligatorie per legge o regolamento, dell’instaurazione ed esecuzione dei rapporti commerciali in essere o in divenire e dei rapporti consulenziali da Lei richiesti come previsti da leggi o regolamenti di settore.</p>";

    String capitolo2 =
        "<p style='text-align:justify;'>Tutti i dati personali e sensibili da Lei conferiti, o già detenuti da <strong>$nomeAgenzia</strong>, oppure raccolti presso altri soggetti e presso altre banche dati, la cui consultazione è prevista per legge o per regolamento, costituiscono oggetto di trattamento. <strong>$nomeAgenzia</strong>  non dispone di mezzi illeciti per ottenere queste informazioni, che saranno utilizzate:<br>1.	per la gestione delle attività specifiche di <strong>$nomeAgenzia</strong>, quale intermediario assicurativo, e degli adempimenti obbligatori quali:<br>•	adempimento degli obblighi previsti da leggi, regolamenti o normative comunitarie, nonché da disposizioni impartite da Autorità a ciò legittimate dalla legge o da organi di vigilanza e di controllo;<br>•	realizzazione dell’attività di consulenza comprendente l’analisi dei Suoi bisogni e le valutazioni delle Sue esigenze assicurative e previdenziali, secondo quanto stabilito dalla normativa CEE 2002/92, dal Codice delle Assicurazioni (D.lgs. n. 209 del 7/9/2005), nonché dal Regolamento IVASS 40/2018;<br>•	erogazione di consulenza e supporto finalizzate alla proposta di prodotti e servizi adeguati alle Sue esigenze;<br>•	gestione, consulenza e supporto in merito alle pratiche di sinistro con le Compagnie di Assicurazioni;<br>•	gestione, consulenza e supporto in merito alle pratiche di reclamo intentate dagli assicurati.<br>2.	per attività di marketing, di promozione commerciale propria o di terzi e di analisi (per cui saranno trattati esclusivamente i dati personali particolari, previo rilascio di opportuno consenso) quali<br>a)	informazione e/o promozione commerciale, per illustrare nuove opportunità di Suo possibile interesse, a mezzo posta, telefono o mediante comunicazioni elettroniche come e-mail, fax, messaggi Sms o MMS e altri sistemi automatizzati disponibili allo<br>scopo, volte a far conoscere i nuovi servizi e prodotti assicurativi adeguati al Suo profilo di rischio e a migliorare prodotti e servizi offerti, così come imposto agli intermediari dalle vigenti normative, fermo restando il Suo diritto di opposizione, in tutto o in parte, per le suddette finalità<br>b)	informazione e/o promozione commerciale, per illustrare nuove opportunità di Suo possibile interesse, a mezzo posta, telefono o mediante comunicazioni elettroniche come e-mail, fax, messaggi Sms o MMS e altri sistemi automatizzati disponibili allo scopo, volte a far conoscere i nuovi servizi e prodotti, anche di terzi, di cui <strong>$nomeAgenzia</strong>  è autorizzato da leggi, normative o appositi mandati e/o contratti, a curare la commercializzazione;<br>c)	ricerche di mercato ed indagini sulla qualità dei servizi e sulla Sua soddisfazione, anche avvalendosi di società specializzate, con l’obiettivo di migliorare l’offerta di prodotti e servizi;<br>d)	comunicazione dei Suoi dati personali verso soggetti terzi, operanti nel settore indicato nella relativa richiesta di consenso, per finalità di informazione e promozione commerciale di prodotti o servizi da parte degli stessi.<br>e)	profilazione volta ad analizzare i Suoi bisogni e le Sue esigenze assicurative per l’individuazione, anche attraverso elaborazioni elettroniche, dei possibili prodotti o servizi in linea con le Sue preferenze e i Suoi interessi.<br>I dati oggetto di profilazione, da cui sono rigorosamente esclusi i dati idonei a rivelare lo stato di salute e la vita sessuale, con riferimento a clienti individuabili, potranno essere conservati per finalità di profilazione per un periodo non superiore a dodici mesi dalla loro registrazione, salva la reale trasformazione in forma anonima che non permetta, anche indirettamente o collegando altre banche dati, di identificare gli interessati: l'attività di profilazione sarà svolta utilizzando dati strettamente necessari al perseguimento delle finalità dichiarate.<br>f)	informazione e/o promozione commerciale, per illustrare nuovi prodotti e/o servizi analoghi a quelli già contrattualizzati (soft spam), a mezzo posta, telefono o mediante comunicazioni elettroniche come e-mail, fax, messaggi Sms o MMS e altri sistemi automatizzati disponibili allo scopo, fermo restando il suo diritto di opposizione, per suddetta finalità.<br>3.	per attività investigative difensive o per far valere o difendere un diritto in sede giudiziaria;<br>Tutti i dati da Lei conferiti sono trattati, quindi, esclusivamente per adempimenti connessi all'attività di <strong>$nomeAgenzia</strong>, le cui basi giuridiche sono rinvenibili nel consenso (es. per il trattamento delle “categorie particolari di dati personali” o per marketing/profilazione) e/o nell’esecuzione di un contratto di nostra gestione di cui Lei è parte o nell’esecuzione di misure precontrattuali adottate su Sua richiesta e/o nell’adempiere a obblighi legali ai quali è soggetto lo scrivente Titolare e/o nel legittimo interesse dello stesso.</p>";

    String capitolo3 =
        "<p style='text-align:justify;'>Il conferimento dei dati personali ed il conseguente trattamento da parte da <strong>$nomeAgenzia</strong>, per le finalità di cui al punto 1, sono necessari per l’instaurazione, per la prosecuzione e per la corretta gestione del rapporto tra Titolare ed Interessato, nonché strettamente necessari alla gestione ed esecuzione dei rapporti in essere o alla gestione dei sinistri: tale conferimento deve pertanto intendersi come obbligatorio in base a legge, regolamento o normativa comunitaria (si cita a titolo esemplificativo e non limitativo, la normativa antiriciclaggio): l’eventuale rifiuto a fornire i dati personali richiesti potrà causare l’impossibilità, in tutto o in parte, di perfezionare e di gestire il rapporto consulenziale in essere o in divenire. Il conferimento dei dati personali ed il conseguente trattamento da parte di <strong>$nomeAgenzia</strong>  per le finalità di cui al punto 2 è facoltativo ed il mancato conferimento, anche parziale, non pregiudicherà l’esecuzione di polizze assicurative eventualmente stipulate, precludendo il solo espletamento delle attività indicate nel punto citato.</p>";

    String capitolo4 =
        "<p style='text-align:justify;'>Il trattamento dei dati personali sarà effettuato sia su supporti cartacei, mediante strumenti manuali, sia con l’ausilio di strumenti elettronici mediante idonee procedure informatiche e telematiche, attraverso sistemi e banche dati di proprietà dello scrivente, atti a memorizzare, gestire e trasmettere i dati, con logiche e modalità tali da garantirne la sicurezza e la riservatezza.<br><strong>$nomeAgenzia</strong>  garantisce che i dati trattati saranno sempre pertinenti, completi e non eccedenti rispetto alle finalità per le quali sono raccolti, con il Suo impegno di comunicare tempestivamente eventuali correzioni, integrazioni o aggiornamenti; specifiche misure di sicurezza sono osservate per prevenire la perdita dei dati, usi illeciti o non corretti ed accessi non autorizzati.</p>";

    String capitolo5 =
        "<p style='text-align:justify;'>I dati personali saranno trattati per il tempo strettamente necessario a conseguire gli scopi, sopra descritti, per adempiere ad obblighi contrattuali, di legge e di regolamento fatti salvi i termini prescrizionali e di legge, nel rispetto dei diritti e in ottemperanza degli obblighi conseguenti.<br>In particolare, criteri utilizzati per determinare il periodo di conservazione sono stabiliti da specifiche norme di legge (che regolamentano l’attività assicurativa), dal periodo di permanenza quale assicurato presso lo scrivente Titolare (soprattutto in relazione alle ‘categorie particolari di dati’ o di ‘profilazione’) e dalla normativa fiscale per quanto riguarda il trattamento dei dati amministrativo-contabili. Con riferimento ai dati raccolti per finalità commerciali (di cui al punto 2), i tempi di conservazione sono limitati – per l’attività di profilazione - a 1 anno dalla data di acquisizione e per l’attività di marketing diretto, a due anni dalla raccolta per i prospect o dal termine del rapporto contrattuale per i clienti. I dati personali dell’assicurato, infine, potranno essere conservati anche fino al tempo permesso dalla legge italiana a tutela degli interessi legittimi della società Titolare (art. 2947, co. 1 e 3 c.c.)’.</p>";

    String capitolo6 =
        "<p style='text-align:justify;'>Il trattamento dei dati personali sarà effettuato, nei limiti delle autorizzazioni di carattere generale rilasciate dal Garante per la protezione dei dati personali, a mezzo di soggetti espressamente e specificamente designati dal Titolare, in qualità di responsabili o incaricati. I dati potranno altresì essere trattati da soggetti terzi (outsourcer), di cui ci si avvale per l’erogazione di servizi connessi alla finalità perseguita, che la nostra organizzazione valuta di volta in volta, per garantire una maggiore tutela, se nominare responsabili dei trattamenti da questi posti in essere. In tutti i casi, tali soggetti tratteranno i dati conformemente alle istruzioni ricevute dal Titolare, secondo profili operativi agli stessi attribuiti in relazione alle funzioni svolte, limitatamente a quanto necessario e strumentale per l’esecuzione di specifiche operazioni nell’ambito dei servizi richiesti ed esclusivamente per il conseguimento delle finalità indicate nella presente informativa. L’elenco dei Responsabili del trattamento, costantemente aggiornato, può essere richiesto inviando una comunicazione con le modalità indicate al successivo punto riguardante i diritti dell’interessato.</p>";

    String capitolo7 =
        "<p style='text-align:justify;'>I dati potranno essere comunicati (intendendo con tale termine il darne conoscenza ad uno o più soggetti determinati, diversi dal Titolare, dai responsabili, interni ma anche esterni alla struttura aziendale, e dagli incaricati al trattamento individuati e nominati per il perseguimento delle finalità sopra indicate ed in ogni caso nei limiti delle stesse, come segue:<br>•	a soggetti, pubblici e privati, quali Autonomi Titolari, che possono accedere ai dati in forza di disposizione di legge, di regolamento o di normativa comunitaria, nei limiti previsti da tali norme;<br>•	a soggetti esterni, anche appartenenti al settore assicurativo e finanziario, che svolgono per conto di <strong>$nomeAgenzia</strong> attività ausiliarie correlate ai trattamenti dei dati, che la nostra organizzazione valuta di volta in volta, per garantire una maggiore tutela, se nominare responsabili dei trattamenti da questi posti in essere o a cui richiede di sottoscrivere specifiche clausole che impongano il dovere di riservatezza, sicurezza e la garanzia di rispetto del Codice Privacy e successive integrazioni. Tali soggetti possono:<br>-	svolgere per nostro conto servizi informatici, telematici, finanziari, amministrativi, di archiviazione, di stampa imbustamento della corrispondenza e di gestione trasporto e smistamento delle comunicazioni alla clientela;<br>-	operare nella c.d. ‘catena assicurativa’ con specifici compiti di natura tecnica, organizzativa ed operativa ovvero soggetti appartenenti alla c.d. ‘catena assicurativa’ (si citano a titolo esemplificativo e non limitativo, imprese di assicurazione, agenti, subagenti, produttori, centri peritali, broker, promotori finanziari, banche, sim) nonché<br>-	avere un ruolo attivo in ragione del rapporto assicurativo con Lei intercorrente (contraenti di polizze in cui si risulti assicurati, beneficiari, coobbligati);<br>-	operare in attività di rilevazione circa la qualità dei servizi forniti, la soddisfazione della clientela, etc.<br>•	a soggetti esterni consulenti di <strong>$nomeAgenzia</strong>, nei limiti necessari per svolgere il loro incarico presso la nostra organizzazione, vincolati dalla sottoscrizione di specifiche clausole o accordi che impongano il dovere di riservatezza, sicurezza e la garanzia di rispetto della normativa italiana ed europea in materia di privacy e successive integrazioni;<br>•	soggetti terzi qualora il trattamento risulti necessario o funzionale agli obblighi di legge e di contratto verso altri soggetti del settore assicurativo con i quali lo scrivente intrattiene o intratterrà rapporti di reciproca collaborazione ai sensi della legge 221/2012;<br>Ove tale comunicazione non fosse possibile senza libero ed esplicito consenso da parte dell’interessato, perché prevista in relazione alle normative vigenti e nell’ambito delle finalità dichiarate, l’espressione del consenso risulterà indispensabile per procedere alla comunicazione stessa verso soggetti che svolgono attività ausiliarie rispetto le finalità dichiarate.<br>I dati non verranno diffusi, con tale termine intendendosi il darne conoscenza a soggetti indeterminati in qualunque modo, anche mediante la loro messa a disposizione o consultazione, a meno di specifico consenso, libero ed informato, concesso per ciascun tipo.</p>";

    String capitolo8 =
        "<p style='text-align:justify;'>Con riferimento agli artt. 15 – diritto di accesso, 16 - diritto di rettifica, 17 – diritto alla cancellazione, 18 – diritto alla limitazione del trattamento, 20 – diritto alla portabilità,21 – diritto di opposizione, 22 diritto di opposizione al processo decisionale automatizzato del GDPR 679/16, il soggetto interessato potrà rivolgere le proprie richieste, così come per conoscere l’elenco aggiornato dei responsabili del trattamento dei dati personali, attraverso specifica comunicazione, a mezzo posta indirizzata alla scrivente Società, o attraverso la casella di posta elettronica: <strong>$emailAgenzia</strong>.<br>I soggetti interessati, cui si riferiscono i dati personali, hanno facoltà di esercitare in ogni momento i diritti (Diritto di accesso ai dati personali ed altri diritti), in particolare: diritto di ottenere la conferma dell’esistenza o meno dei propri dati personali, di accedervi e di conoscerne il contenuto e l’origine, di verificarne l’esattezza, di chiederne l’integrazione o l'aggiornamento, limitazione del trattamento o portabilità. La rettificazione e il blocco possono essere richiesti se i dati risultano incompleti, erronei o raccolti in violazione della normativa vigente ed in tal senso è anche possibile opporsi al loro trattamento per motivi legittimi o a qualsiasi processo decisionale automatizzato (compreso la profilazione), così come è possibile richiedere, per gli stessi motivi anche la cancellazione purché in conformità alle norme vigenti e qualora non esistano altri obblighi di conservazione e trattamento in capo a <strong>$nomeAgenzia</strong>. I soggetti interessati hanno, altresì, il diritto di opposizione al trattamento dei propri dati personali per le finalità di marketing (indicate al punto 2), anche se effettuato con modalità automatizzate di contatto; tale diritto si estende anche a quelle tradizionali e i soggetti interessati potranno esercitare tali diritti in tutto o in parte (es. solo alle comunicazioni tramite sms, e-mail o telefono ovvero opponendosi al solo invio di comunicazioni promozionali effettuato tramite strumenti automatizzati, etc.).</p>";

    String capitolo9 =
        "<p style='text-align:justify;'>Il Titolare del trattamento dei dati personali è <strong>$nomeAgenzia</strong> con sede in <strong>$indirizzoAgenzia</strong>. Il Titolare conserva una lista aggiornata dei responsabili nominati, e ne garantisce la presa visione all’interessato presso la sede sopra indicata.</p>";

    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HtmlWidget(
                "<h2 style='text-align:center;'>Informativa sulla Tutela dei dati personali</h2>",
              ),
              constants.SPACER_MEDIUM,
              HtmlWidget(capitolo1),
              constants.SPACER,
              const HtmlWidget(
                "<h2 style='text-align:center;'>Finalità di trattamento e base giuridica</h2>",
              ),
              constants.SPACER_MEDIUM,
              HtmlWidget(capitolo2),
              constants.SPACER,
              const HtmlWidget(
                "<h2 style='text-align:center;'>Natura obblicatoria e facoltativa del conferimento dei dati e conseguenze di un eventuale rifiuto</h2>",
              ),
              constants.SPACER_MEDIUM,
              HtmlWidget(capitolo3),
              constants.SPACER,
              const HtmlWidget(
                "<h2 style='text-align:center;'>Modalità di trattamento</h2>",
              ),
              constants.SPACER_MEDIUM,
              HtmlWidget(capitolo4),
              constants.SPACER,
              const HtmlWidget(
                "<h2 style='text-align:center;'>Tempi di conservazione</h2>",
              ),
              constants.SPACER_MEDIUM,
              HtmlWidget(capitolo5),
              constants.SPACER,
              const HtmlWidget(
                "<h2 style='text-align:center;'>Ambito di conoscenza dei dati</h2>",
              ),
              constants.SPACER_MEDIUM,
              HtmlWidget(capitolo6),
              constants.SPACER,
              const HtmlWidget(
                "<h2 style='text-align:center;'>Comunicazione e diffusione</h2>",
              ),
              constants.SPACER_MEDIUM,
              HtmlWidget(capitolo7),
              constants.SPACER,
              const HtmlWidget(
                "<h2 style='text-align:center;'>Diritti dell'interessato</h2>",
              ),
              constants.SPACER_MEDIUM,
              HtmlWidget(capitolo8),
              constants.SPACER,
              const HtmlWidget(
                "<h2 style='text-align:center;'>Titolare del trattamento</h2>",
              ),
              constants.SPACER_MEDIUM,
              HtmlWidget(capitolo9),
            ],
          ),
        ),
      ),
    );
  }
}
