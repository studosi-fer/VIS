---
title: "VIS - Labosi (drugi ciklus)"
subtitle: "Pouzdani intervali i testiranje hipoteza u R-u"
author: "Vanessa Keranović, Kristijan Kilassa Kvaternik, Mate Puljiz, Stjepan Šebek, Josip Žubrinić"
#date: "??.??.2019."
output: pdf_document
header-includes: \usepackage{enumerate}
---

```{r, echo = FALSE}
library(knitr)
opts_chunk$set(tidy.opts = list(width.cutoff = 60), tidy = F)
set.seed(1)
```

\def\geom{\mathcal{G}}
\def\bin{\mathcal{B}}
\def\poiss{\mathcal{P}}
\def\exp{\mathcal{E}}
\def\norm{\mathcal{N}}
\renewcommand{\P}{\mathbb{P}}
\def\E{\mathbb{E}}
\def\D{\mathbb{D}}
\def\cov{\operatorname{cov}}
\def\Hn{\mathcal{H}_0}
\def\Ha{\mathcal{H}_1}


# Uvod

Labosi na predmetu "Vjerojatnost i statistika" izvode se u programskom jeziku R, radnoj okolini RStudio, u obliku R Markdown izvještaja koji kombiniraju pisanje teksta s programskim kodom i rezultatima izvođenja koda. Predznanje ovih alata nije nužno za izvedbu jer se kroz labose demonstriraju ključne funkcionalnosti. Kao dodatne materijale preporučamo udžbenik "Programirajmo u R-u" doc. dr. sc. Damira Pintara, dostupan na stranicama vještine "Osnove programskog jezika R"  (<https://www.fer.unizg.hr/predmet/opjr>).


### RStudio u oblaku

RStudio moguće je isprobati i bez lokalne instalacije na vašem računalu. Dovoljno je otići na stranicu \url{https://rstudio.cloud}, registrirati se i započeti s programiranjem.


### R Markdown

R Markdown dokument sastavljen je od isječaka koda u R-u i teksta oko njih. Trenutnu liniju koda izvodimo kombinacijom tipaka `CTRL+ENTER`, a cijeli isječak kombinacijom `CTRL+SHIFT+ENTER`. Iz R Markdown dokumenta moguće je stvoriti izvještaj u PDF, HTML, DOCX ili drugim formatima (`output` parametar u zaglavlju dokumenta) kombinacijom tipaka `CTRL+SHIFT+K`. 

\pagebreak

# Auditorne vježbe (12. tjedan)

U nastavku ćemo pokazati kako se neki zadaci rješavaju u R-u. Uz kôd, pronaći ćete i klasična rješenja istih zadataka. Napominjemo da ćete **za ispit morati znati rješavati zadatke klasičnom metodom (papir, olovka, tablice, kalkulator)**. Dio završnog ispita će se također sastojati od kratkih pitalica gdje ćemo ispitati vašu sposobnost da iščitate output kraćeg R programa i na temelju toga donesete valjane statističke zaključke.

## Zadatak 1.

Registrirana su vremena (u minutama) između uzastopnih poziva u telefonskoj centrali: $8, 12, 7, 10, 5$. Ako znamo da se vrijeme između uzastopnih poziva ravna po eksponencijalnoj razdiobi s parametrom $\lambda$, pomoću kriterija najveće izglednosti odredite procjenu za parametar $\lambda$. Kolika je vjerojatnost da će se na sljedeći poziv čekati više od $5$ minuta?


### Rješenje

$$ f(\lambda,x)=\lambda e^{-\lambda x},\quad x>0,$$
$$ L(\lambda,x_1,\ldots, x_n) =  f(\lambda,x_1)\cdots f(\lambda,x_n)=\lambda^n e^{-\lambda \sum_{i=1}^n x_i} $$
$$ \frac{\partial L}{\partial\lambda} = n\lambda^{n-1}e^{-\lambda \sum_{i=1}^n x_i} - \lambda^n e^{-\lambda \sum_{i=1}^n x_i} \sum_{i=1}^n x_i 
=\lambda^{n-1}e^{-\lambda \sum_{i=1}^n x_i}(n-\lambda \sum_{i=1}^n x_i) $$
$$ \frac{\partial L}{\partial\lambda} =0, \text{ za } \lambda=0  \text{ ili } \lambda= \frac{n}{\sum_{i=1}^n x_i} $$
$$ \hat\lambda = \frac{1}{\overline x} =\frac1{\frac{8+12+7+10+5}{5}}=0.119$$
$$X\sim \exp(0.119),\quad \P(X>5)=e^{-5\lambda}=0.55 $$
Gornji zadatak možemo riješiti i u R-u. Trebat će nam funkcija `fitdistr` iz paketa `MASS` koja procjenjuje parametre distribucije metodom najveće izglednosti (MLE od *engl.* maximum likelihood estimation).

```{r}
sample = c(8, 12, 7, 10, 5)
fit = MASS::fitdistr(sample, 'exponential')
```

Estimirani $\lambda$ koristimo za računanje tražene vjerojatnosti koristeći funkciju `pexp`.

```{r}
lambda_est = fit$estimate
1 - pexp(5, rate = lambda_est)
```

$$***$$

Sve standardne distribucije su implementirane u R-u. Primjerice `dexp` daje funkciju gustoće, `pexp` funkciju razdiobe (kumulativnu funkciju distribucije), `qexp` daje kvantile, a `rexp` generira slučajan uzorak iz eksponencijalne distribucije.

Analogno imamo funkcije `dnorm`, `pnorm`, `qnorm` i `rnorm` za normalnu distribuciju; `dpois`, `ppois`, `qpois` i `rpois` za Poissonovu; `dbinom`, `pbinom`, `qbinom` i `rbinom` za binomnu distribuciju i slično.

## Zadatak 2.

Uzorak $x_1,x_2,\dots,x_n$ izvučen je iz populacije koja se ravna po geometrijskoj razdiobi. Pomoću kriterija najveće izglednosti odredite procjenu za parametar $p$.

### Rješenje

$$ f(p,x)=p (1-p)^{x-1},\quad x=1,2,3,\ldots$$
$$ L(p,x_1,\ldots, x_n) =  f(p,x_1)\cdots f(p,x_n)=p^n (1-p)^{ \sum_{i=1}^n x_i-n } $$
$$\ln L = n \ln p + (\sum_{i=1}^n x_i-n)\ln(1-p)$$
$$ \frac{\partial \ln L}{\partial p} =  \frac np-\frac{\sum_{i=1}^n x_i-n}{1-p}$$
$$ \frac{\partial \ln L}{\partial p}=0, \text{ za } p= \frac{n}{\sum_{i=1}^n x_i} $$
$$ \hat p = \frac{1}{\overline x}$$

Ovaj zadatak ne možemo riješiti u R-u ali možemo provjeriti da dobiveno rješenje odgovara onome što bismo izračunali u R-u za neku konkretnu situaciju.

Generirat ćemo uzorak duljine 1000 iz $\geom(0.2)$, izračunati $\bar{x}$ i provjeriti da `MASS::fitdistr` daje $\frac{1}{\bar{x}}$. No trebamo biti pažljivi jer je u R-u geometrijska distribucija implementrana da počinje od 0 te stoga **donji kôd daje krivi rezultat**.

```{r}
sample = rgeom(1000, 0.2)
1 / mean(sample)
MASS::fitdistr(sample, 'geometric')
```

Ispod je modificirani kôd. Vidimo da sada dobivamo iste brojeve kao što smo i očekivali.

```{r}
sample = rgeom(1000, 0.2)
1 / mean(sample + 1)
MASS::fitdistr(sample, 'geometric')
```

**(DZ)** \quad Pokažite da je procjenitelj najveće izglednosti (MLE) za parametar $p$ geometrijske razdiobe koja počinje od 0 jednak $\frac{1}{\bar{x}+1}$.

## Zadatak 3.

Iz generalnog skupa koji ima normalnu razdiobu s devijacijom $\sigma = 0.5$ i nepoznatim očekivanjem, izvučen je uzorak volumena $8$: $16, 16, 16, 16.2, 16.2, 16.2, 16.5, 16.5$. Odredite procjenu i $90\%$ pouzdani interval za matematičko očekivanje $a$.

### Rješenje

$$ X\sim \norm(a,\sigma^2),\quad \sigma= 0.5 $$
Interval povjerenja reda $1-\alpha$ za očekivanje normalne razdiobe, uz poznati $\sigma^2$:
$$ \P (\overline x -u_{1-\alpha/2} \frac{\sigma}{\sqrt n} < a <  \overline x +u_{1-\alpha/2}\frac{\sigma}{\sqrt n} )=1-\alpha=0.9,$$
$$\quad\alpha=0.1, \quad 1-\alpha/2=0.95, \quad u_{1-\alpha/2} = 1.645, \quad \overline x=16.2,	\quad n = 8 $$ 
$$  \P (15.9092 < a <  16.4908)= 0.9 $$
Ovaj zadatak u R-u rješavamo isto kao i na papiru uz razliku da ne moramo posezati za tablicama jer R ima ugrađene funkcije za kvantile.

```{r}
sample = c(16, 16, 16, 16.2, 16.2, 16.2, 16.5, 16.5)
sigma = 0.5
confidence = 0.9
n = length(sample)
mean = mean(sample)
alpha = 1 - confidence
d = sigma * qnorm(1 - alpha / 2) / sqrt(n)
c(mean - d, mean + d)
```

## Zadatak 4.

Iz populacije koja se podvrgava normalnom zakonu izvučen je sljedeći uzorak:
\begin{center}
\begin{tabular}{c | c c c c c c}
$x_j$ & $110$ & $115$ & $120$ & $125$ & $130$ & $135$ \\
\hline
$n_j$ & $2$ & $3$ & $6$ & $5$ & $2$ & $2$
\end{tabular}	
\end{center}
Izračunajte procjenu i $90\%$ pouzdani interval za matematičko očekivanje i disperziju.

### Rješenje

$$ X\sim \norm(a,\sigma^2)$$

Interval povjerenja reda $1-\alpha$ za očekivanje normalne razdiobe, uz nepoznati $\sigma^2$:
$$ \P \left(\overline x -t_{n-1,1-\alpha/2} \frac{\hat s}{\sqrt n} < a <  \overline x +t_{n-1,1-\alpha/2}\frac{\hat s}{\sqrt n} \right)=1-\alpha=0.9,$$
$$\quad\alpha=0.1, \quad  n=20, \quad t_{n-1,1-\alpha/2} = t_{19,1-\alpha/2}=1.729,$$
$$	\quad \overline x=\sum_{j=1}^6 n_j x_j =122,	
\quad \hat s^2 = \frac1{n-1}\sum_{j=1}^6 n_jx_j^2-n\overline x^2 = 51.05263,
\quad \hat s = 7.145112$$ 
$$ \P (119.2374 < a <  124.7626 )=0.9$$
I ovdje kao i u prethodnom zadatku bismo mogli čitav ovaj postupak prepisati u R uz korištenje funkcije `qt` za kvantile Studentove $t$-distribucije (**napravite to za DZ**). No moguće je dobiti i traženi interval za $a$ u jednom koraku koristeći činjenicu da je kritično područje $t$-testa (koji je implementiran u R-u) zapravo traženi interval pouzdanosti. Više o vezi intervala pouzdanosti i statističkih testova možete pročitati u dodatku na kraju ovoga dokumenta.

U sljedećem kodu smo iskoristili funkciju `rep` koja ponavlja vrijednosti iz vektora `xi` s frekvencijama `fi` čime smo iz frekvencijske tablice kreirali uzorak iz kojeg je dobivena ta tablica.

```{r}
xi = c(110, 115, 120, 125, 130, 135)
fi = c(2, 3, 6, 5, 2, 2)
sample = rep(xi, fi)
sample
```

Sada provedemo $t$-test uz razinu značajnosti $0.1$ (koja odgovara pouzdanosti od 90%) i očitamo traženi pouzdani interval. Ovdje nije bitno što uzimamo za nul-hipotezu budući da nas zanima samo interval pouzdanosti.

```{r}
t.test(sample, conf.level = 0.9)
```

Napomenimo još da $t$-test nismo mogli koristiti u zadatku 3 budući da je tamo disperzija bila poznata. Za zadatak 3 je bio potreban $u$-test (koji se u literaturi učestalije zove $Z$-testom) a koji pak nije implementiran u R-u.

Sada računamo interval povjerenja reda $1-\alpha$ za disperziju normalne razdiobe, uz nepoznato očekivanje $a$:
$$ \P \left( \frac{(n-1)\hat s^2}{\chi^2_{n-1,1-\alpha/2}} < \sigma^2 <  \frac{(n-1)\hat s^2}{\chi^2_{n-1,\alpha/2}} \right)=1-\alpha=0.9,$$
$$ \chi^2_{n-1,1-\alpha/2}= \chi^2_{19,0.95}=30.144,
\quad \chi^2_{n-1,\alpha/2}= \chi^2_{19,0.05} = 10.117$$
$$ \P \left( 32.179 < \sigma^2 < 95.878 \right) = 0.9,$$
Pouzdani interval za disperziju (varijancu) u R-u možemo računati "pješke".

```{r}
df = length(sample) - 1
var = var(sample)
confidence = 0.9
alpha = 1 - confidence
lower = var * df / qchisq(1 - alpha / 2, df)
upper = var * df / qchisq(alpha / 2, df)
c(lower, upper)
```

No, postoji i funkcija koji može računati taj interval direktno, ali preko testa kojeg nećemo obrađivati u ovom kolegiju. Potrebna funkcija `varTest` se nalazi u paketu `EnvStats` i pristupamo joj naredbom `EnvStats::varTest`.

```{r}
EnvStats::varTest(sample, conf.level = 0.9)
```

## Zadatak 5.

Kontrolom 100 žarulja iz određene velike pošiljke ustanovljeno je da ima 6 loših žarulja.

\begin{enumerate}[(a)]
\item  Odredite 95\%-tni interval povjerenja za postotak loših žarulja.
\item  Koliki broj žarulja $n$ treba kontrolirati da bi se s pouzdanoću 0.95 moglo tvrditi da u čitavoj pošiljci nema \emph{više od} 9\% loših žarulja? Pretpostavite da se opet dobije isti točkovni procjenitelj $\hat{p}=0.06$.
\end{enumerate}

### Rješenje

U ovom zadatku koristimo pouzdane intervale za vjerojatnost događaja $p$. Oni nisu egzaktni već se temelje na aproksimaciji binomne slučajne varijable normalnom distribucijom koja proizlazi iz centralnog graničnog teorema. Konkretno, za $X\sim \bin(n,p)$ vrijedi $X \approx \norm\left(np,np(1-p)\right)$ odnosno

$$\frac{1}{n}X \approx \norm\left(p,\frac{p(1-p)}{n}\right).$$

Ova aproksimacija nije najbolja ukoliko je $n$ mali, ili ako je $p$ preblizu $0$ ili $1$. Običaj je zahtjevati  da je $np>5$ i $n(1-p)>5$.

\medskip

(a) Označimo li s $X$ *slučajan broj* loših žarulja od 100 ispitanih onda je $X\sim\bin(100,p)$ gdje je $p$ pravi postotak loših žarulja u čitavoj velikoj pošiljci. Procjenitelj $\hat{p} = \frac{1}{100}X$ je onda približno distribuiran kao $\norm\left(p,\frac{p(1-p)}{100}\right)$ a 95%-pouzdani interval računamo kako slijedi:
$$ \P (p_1\le p\le p_2)=1-\alpha,
\quad p_{1,2}=\hat{p}\mp u_{1-\alpha/2} \sqrt{\frac{\hat{p} (1 - \hat{p})}{n}},
\quad\hat p=\frac mn,$$
$$ 1-\alpha=0.95, \quad\alpha=0.05, \quad 1-\alpha/2=0.975, \quad u_{1-\alpha/2} = 1.95996,\quad \hat{p} = 0.06,
\quad n = 100 $$ 
$$p_1=0.0134535,\quad p_2= 0.106546$$
Ili u R-u:
```{r}
xi = c('D', 'L')
fi = c(94, 6)
sample = rep(xi, fi)
n = length(sample)
confidence = 0.95
alpha = 1 - confidence
p_est = sum(sample == 'L') / n
d = qnorm(1 - alpha / 2) * sqrt(p_est * (1 - p_est) / n)
c(p_est - d, p_est + d)
```
Već smo rekli da su ovi intervali pouzdanosti aproksimativni što znači da su izvedeni uz pretpostavku da promatrana varijabla $X$ ima normalnu distribuciju. U R-u se mogu dobiti i pravi intervali pouzdanosti gdje je uzeta u obzir prava (binomna) distribucija varijable $X$. Trebamo samo iskoristiti funkciju `binom.test`
```{r}
no_of_succeses = sum(sample == 'L')
binom.test(no_of_succeses, 100, alternative = 'two.sided', conf.level = confidence)
```

(b) Zadatak nas pita da odredimo $n$ takav da uz $\alpha=0.05$ možemo odbaciti hipotezu $p\ge 0.09$. Očigledno moramo uzeti da je nul-hipoteza $\Hn \dots p = 0.09$ uz alternativu $\Ha \dots p < 0.09$. Radi se, jasno, o testu o proporciji. Testna statistika je
$$U=(\hat{p}-0.09)\sqrt{\frac{n}{0.09\cdot 0.91}}\,,\quad \hat{p}=0.06$$
a $\Hn$ odbacujemo ukoliko je $U<-u_{1-\alpha}$. To znači da mora vrijediti
$$0.03\sqrt{\frac{n}{0.09\cdot 0.91}}>u_{0.95} =1.644854$$
odnosno $n>246.2045$, pa moramo ispitati barem 247 žarulja.

U R-u ne možemo direktno riješiti ovaj problem, ali možemo koristeći `binom.test` provjeriti da se naš $n$ slaže s onim što bismo dobili testiranjem uzorka od 247 žarulja u koje smo prebrojali 15 loših ($247\cdot 0.06=14.82$).
```{r}
binom.test(15, 247, alternative = 'less', p = 0.09)
```
Vidimo da je $p$-vrijednost veća od $\alpha=0.05$ što znači da ne bismo mogli odbaciti $\Hn$, što bi onda upućivalo da smo krivo riješili zadatak i da je potreban veći $n$. No sjetite se da smo pri rješavanju koristili test proporcija u kojem je statistika samo aproksimativno normalna, dok R koristi egzaktnu distribuciju pa pogrešku možemo pripisati lošoj aproksimaciji.

Metodom pokušaja i pogreške (ili jednostavno zavrtimo petlju) možemo pronaći koji bi $n$ bio dovoljan da egzaktni binomni test odbaci $\Hn$.

```{r}
for(n in 1:500){
  test = binom.test(ceiling(n*0.06), n, alternative = 'less', p = 0.09)
  if (test$p.value<0.05) {
    print(n)
    break
  }
}
```


\pagebreak

# Auditorne vježbe (13. tjedan)

## Zadatak 1.
Slučajna varijabla $X$ je normalno distribuirana s nepoznatim očekivanjem i nepoznatom disperzijom.
Uzorak od $n = 50$ mjerenja (zapisanih u datoteci `zad1.csv`) dao je srednju vrijednost $\bar{x} = 24.2$ i $\hat{s} = 4.8$. Uz nivo značajnosti $\alpha = 0.05$
testirajte hipotezu $\Hn \dots a=25$ uz alternativu $\Ha \dots a < 25$.

### Rješenje

Prvo učitajmo podatke iz datoteke i uvjerimo se da su $\bar{x}$ i $\hat{s}$ točno izračunati.

```{r}
sample = read.csv('zad1.csv')$xi
n = length(sample)
c(mean(sample), sqrt(var(sample)))
```

Koristimo $t$-test, uz statistiku
$$T = \frac{\bar{x}-a}{\hat{s}/\sqrt{n}} = \frac{24.2-25.0}{4.8/\sqrt{50}} = -\frac{5\sqrt{2}}{6}\approx-1.178511$$

Radi se o jednostranoj alternativi pa je kritično područje oblika $T<-t_{49, 0.95}$. To znači da bismo, ukoliko je $T<-t_{49, 0.95}$, nul-hipotezu morali odbaciti. Budući da je
$$T>-1.66>-t_{60,0.95}>-t_{49,0.95}$$
onda $\Hn$ **ne odbacujemo**.

Umjesto korištenja tablica, u R-u bismo mogli direktno računati $-t_{49, 0.95}=t_{49, 0.05}$.

```{r}
-qt(0.95,49)
```

No moguće je i sprovesti čitav test direktno iz podataka koristeći funkciju `t.test`.

```{r}
alpha = 0.05
confidence = 1 - alpha
t.test(sample, mu = 25, alternative = 'less', conf.level = confidence)
```
Uočite da je dobivena ista testna statistika $T=-1.1785$. No R neće zapisati kritični interval, već nam izračuna $p$-vrijednost. Sjetimo se da je **$\boldsymbol{p}$-vrijednost broj koji označava najmanju razinu značajnosti uz koju bismo odbacili nul-hipotezu**. Dakle, ukoliko je *$p$-vrijednost manja od zadane razine značajnosti $\alpha$, odbacujemo $\Hn$*, u suprotnom je ne odbacujemo.

Drugi način kako se može definirati $p$-vrijednost jest da je to **vjerojatnost (uz pretpostavku da vrijedi $\Hn$) da se za testnu statistiku dobije upravo vrijednost koju smo dobili ili neku još ekstremniju vrijednost koja bi još više išla u prilog alternativi**.

U našem slučaju bi ekstremnije vrijednosti bile $T<-1.1785$ pa je $p$-vrijednost upravo broj $p$ takav da je $t_{49,p}=-1.1785=T$ i može ga se dobiti preko funkcije razdiobe $t$-distribucije.

```{r}
pt(-1.1785, 49)
```

Budući da je $p$-vrijednost veća od zadane razine značajnosti $\alpha$ ($0.1221 > 0.05$) nul-hipotezu $\Hn$ **ne odbacujemo**.

Uočite da što je $p$-vrijednost manja, to s većom pouzdanošću (tj.\ manjim $\alpha$) možemo odbaciti nul-hipotezu. Obratno, što je $p$-vrijednost veća, to su dani podaci više u skladu s nul-hipotezom.

## Zadatak 2.
Pseudoslučajnim generatorom simulirano je bacanje novčića 10000 puta. Pismo je registrirano 5120 puta.
S kojim nivoom značajnosti možemo potvrditi hipotezu o ispravnosti generatora?

### Rješenje

Koristit ćemo test o proporciji. Označimo li s $p$ vjerojatnost da novčić padne na pismo, a s $P$ broj pisama dobivenih u 10000 bacanja, vrijedi
$$P\sim \bin(10000,p).$$
Postavimo sada nul-hipotezu $\Hn \dots p=\frac{1}{2}$ u odnosu na (dvostranu) alternativu $\Ha \dots p\neq \frac{1}{2}$.

Računamo testnu statistiku
$$U=\left(\frac{5120}{10000}-\frac{1}{2}\right)\sqrt{\frac{10000}{(1/2)\cdot(1/2)}} = 2.4$$
Budući da imamo dvostranu alternativu, kritično područje je oblika $|U|>u_{1-\alpha/2}$. Stoga ćemo potvrditi tezu o ispravnosti generatora (prihvatiti $\Hn$) ukoliko je $|2.4|\le u_{1-\alpha/2}$ odnosno ukoliko je $0.992\le 1-\alpha/2$, tj.\ $\alpha \le 0.016$. Dakle, za nivo značajnosti $\alpha\le 0.016$ možemo prihvatiti tezu o ispravnosti generatora. Ekvivalentno, za svaki $\alpha> 0.016$ bismo odbacili $\Hn$ pa je $0.016$ ujedno i $p$-vrijednost ovog testa.

U R-u bismo sve ove korake mogli postepeno računati, no možemo i direktno sprovesti test. Prvo upišemo podatke:
```{r}
xi = c('P', 'G')
fi = c(5120, 4880)
sample = rep(xi, fi)
#sample
```
a zatim koristeći `binom.test` testiramo našu hipotezu.
```{r}
no_of_succeses = sum(sample == 'P')
n = length(sample)
binom.test(no_of_succeses, n)
```
R koristi egzaktni binomni test dok smo mi koristili aproksimaciju binomne distribucije normalnom. Unatoč tome, uočite da se dobivena $p$-vrijednost $0.01684$ približno podudara s našom.

Dodatno, ispisan je $95\%$-pouzdan interval za vjerojatnost pisma. Uočite da on ne sadržava vrijednost $0.5$. To je stoga što bismo na razini značajnosti $\alpha = 0.05 = 1-0.95$ morali odbaciti $\Hn$ u korist $\Ha$.

## Zadatak 3.
Rezultati mjerenja slučajne varijable $X$ dani su u tablici:
\begin{center}
\begin{tabular}{c|rrrrr}
$j$ & 0 & 1 & 2 & 3 & 4\\
\hline
$n_j$ & 132 & 48 & 20 & 3 & 2
\end{tabular}
\end{center}

Pomoću $\chi^2$-testa provjerite hipotezu da se ovi podaci ravnaju po Poissonovoj razdiobi uz nivo značajnosti 0.05.

### Rješenje

Provjeravamo hipotezu $X\sim \poiss(\lambda)$. Budući da je $\E X = \lambda$ uzimamo procjenitelj $\hat{\lambda} = \bar{x}$. Može se pokazati da je to procjenitelj najveće izglednosti (MLE) (**napravite to za DZ**).
$$\hat{\lambda} = \bar{x} = \frac{\sum j\,n_j}{\sum n_j} = \frac{105}{205}\approx 0.5122$$

```{r}
xi = 0:4
fi = c(132, 48, 20, 3, 2)
n=sum(fi)
sample = rep(xi, fi)
lambda_est = mean(sample)
lambda_est
```
ili
```{r}
MASS::fitdistr(sample,'poisson')
```

Koristit ćemo $\chi^2$-test prilagodbe razdiobama. Sastavljamo tablicu
\begin{center}
\begin{tabular}{rrrrrr}
$j$ & $n_j$ & $p_j$ & $n\,p_j$ & $\Delta = n_j-n\,p_j$ & $\Delta^2/(n\,p_j)$ \\
\hline
0 & 132 & 0.5992 & 122.83 & 9.17 & 0.68 \\
1 & 48 & 0.3069 & 62.91 & -14.91 & 3.54 \\
2 & 20 & 0.0786 & 16.11 & 3.89 & 0.94 \\
3 & 3 & 0.0134 & 2.75 & 0.25 & 0.02 \\
$\ge 4$ & 2 & 0.0019 & 0.39 & 1.61 & 6.60 \\
\end{tabular}
\end{center}
gdje je $\displaystyle p_j=\P(X=j)=\frac{\lambda^j e^{-\lambda}}{j!}$.

Brojeve u gornjoj tablici možemo računati u R-u ovako
```{r}
probs = dpois(xi, lambda_est)
probs[5] = 1 - sum(probs[1:4])

fi
probs
n*probs
fi-n*probs
(fi-n*probs)^2/(n*probs)
```
Sjetmo se da je statistika u ovom slučaju aproksimativno $\chi^2$ i da bi ta aproksimacija bila valjana običaj je zahtjevati da *očekivane* (a ne opažene) frekvencije u svakom razredu budu barem 5. U našem slučaju to znači da moramo zajedno grupirati posljednja tri razreda u jedan. Nova tablica izgleda ovako:
\begin{center}
\begin{tabular}{rrrrrr}
$j$ & $n_j$ & $p_j$ & $n\,p_j$ & $\Delta = n_j-n\,p_j$ & $\Delta^2/(n\,p_j)$ \\
\hline
0 & 132 & 0.5992 & 122.83 & 9.17 & 0.68 \\
1 & 48 & 0.3069 & 62.91 & -14.91 & 3.54 \\
$\ge 2$ & 25 & 0.0939 & 19.25 & 5.75 & 1.72 \\
\end{tabular}
\end{center}

Sada dobivamo $\chi^2$ statistiku $\chi^2_q = 5.94$ koju uspoređujemo s $\chi^2_{1, 0.95} \approx 3.841$ jer je broj stupnjeva slobode $f=3-1-1=1$. Budući da je $5.94 > 3.841$ na razini značajnosti $0.05$ **odbacujemo $\Hn$ da podaci dolaze iz Poissonove razdiobe**.

U R-u bismo ovaj test sproveli na sljedeći način.
```{r}
chisq.test(fi, p = probs)
```
Uočite da nas i R upozorava da aproksimacija može biti pogrešna jer nismo grupirali posljednja tri razreda u jedan.
```{r}
c(fi[1:2], sum(fi[3:5]))
n*c(probs[1:2], sum(probs[3:5]))

chisq.test(c(fi[1:2], sum(fi[3:5])), p = c(probs[1:2], sum(probs[3:5])))
```
Sada vidimo da upozorenja više nema. No još uvijek imamo jedan problem. Naime, broj stupnjeva slobode `df` bi u našem slučaju trebao biti $3-1-1=1$, a ne $2$ kako gore piše, budući da smo procjenjivali parametar $\lambda$ iz podataka. Nažalost, funkcija `chisq.test` nema podržanu tu opciju pa ćemo morati sami provesti test do kraja zanemarujući gore dobivenu $p$-vrijednost (po kojoj **krivo** ispada da ne odbacujemo $\Hn$).

Ono što ipak možemo koristiti jest gore izračunata statistika $\chi^2_q = 5.9341$ (koja se podudara s prije izračunatom). Pravu $p$-vrijednost onda dobijemo koristeći funkciju `pchisq` uz parametar `df=1`.

```{r}
1-pchisq(5.9341, df = 1)
```

Ekvivalentno, mogli smo odrediti kritično područje $(\chi^2_{1, 0.95},+\infty)$ koristeći funkciju `qchisq` opet uz `df=1`.

```{r}
qchisq(0.95, df = 1)
```

Budući da je testna statistika u kritičnom području $5.9341>\chi^2_{1, 0.95}$ (ili ekvivalentno jer je $p$-vrijednost manja od zadane razine značajnosti $0.01485<\alpha$) na zadanoj razini značajnost **odbacujemo nul-hipotezu** da se podaci ravnaju po Poissonovoj razdiobi.


## Zadatak 4.
U Mendelovim eksperimentima s graškom ispitano je 560 zrna i dobiveno je:
\begin{itemize}
\item 317 okruglih i žutih
\item 109 okruglih i zelenih
\item 102 smežuranih i žutih
\item 32 smežurana i zelena.
\end{itemize}
Prema njegovoj teoriji o naslijeđivanju, ovi brojevi bi morali biti u omjeru $9:3:3:1$. S nivoom značajnosti 0.05 odredite treba li prihvatiti ovu pretpostavku.

### Rješenje

Opet ćemo koristiti $\chi^2$-test prilagodbe razdiobama. Nul-hipoteza $\Hn$ jest da su vjerojatnosti dobivanja različitih tipova graška u omjeru $9:3:3:1$. Računamo tablicu
\begin{center}
\begin{tabular}{rrrrrr}
$j$ & $n_j$ & $p_j$ & $n\,p_j$ & $\Delta = n_j-n\,p_j$ & $\Delta^2/(n\,p_j)$ \\
\hline
OY & 317 & 9/16 & 315 & 2 & 0.013 \\
OZ & 109 & 3/16 & 105 & 4 & 0.152 \\
SY & 102 & 3/16 & 105 & -3 & 0.086 \\
SZ & 32 & 1/16 & 35 & -3 & 0.257 \\
\end{tabular}
\end{center}
```{r}
xi = c('OY', 'OZ', 'SY', 'SZ')
fi = c(317, 109, 102, 32)
n=sum(fi)
sample = rep(xi, fi)

probs = c(9,3,3,1)/16

fi
probs
n*probs
fi-n*probs
(fi-n*probs)^2/(n*probs)
sum((fi-n*probs)^2/(n*probs))
```
Dobivamo $\chi^2_q \approx 0.5079$, uz $f=4-1=3$ stupnja slobode imamo $\chi^2_{3, 0.95} = 7.8147$ pa **ne odbacujemo već prihvaćamo nul-hipotezu o omjerima**.

U R-u test izgleda ovako:
```{r}
chisq.test(fi, p=probs)
```
Iz njega čitamo da je $p$-vrijednost veća od $\alpha = 0.05$ pa **ne odbacujemo već prihvaćamo $\Hn$**. Dodatno uočite da je $p$-vrijednost jako visoka što znači da se podaci jako dobro slažu s nul-hipotezom (a što je bilo vidljivo i iz tablice).

## Zadatak 5.
4 kovana novčića bačena su istovremeno 96 puta i svaki puta je zabliježen broj grbova:
\begin{center}
\begin{tabular}{c|rrrrr}
$i$ & 0 & 1 & 2 & 3 & 4\\
\hline
$f_i$ & 5 & 26 & 34 & 24 & 7
\end{tabular}
\end{center}
S nivoom značajnosti 0.05 odredite slažu li se dobiveni rezultati s hipotezom o ispravnosti svih novčića.

### Rješenje

Označimo li s $X$ broj grbova kad bacimo 4 novčića, zadatak nas traži da provjerimo da je $X\sim\bin(4,0.5)$. Za nul-hipotezu uzimamo $\Hn \dots p_0=0.5$ gdje je $X\sim\bin(4,p_0)$, a alternativu uzimamo dvostranu $\Ha \dots p_0\neq 0.5$.

Tablica glasi:
\begin{center}
\begin{tabular}{rrrrrr}
$j$ & $n_j$ & $p_j$ & $n\,p_j$ & $\Delta = n_j-n\,p_j$ & $\Delta^2/(n\,p_j)$ \\
\hline
0 & 5 & 1/16 & 6 & -1 & 1/6 \\
1 & 26 & 4/16 & 24 & 2 & 1/6 \\
2 & 34 & 6/16 & 36 & -2 & 1/9 \\
3 & 24 & 4/16 & 24 & 0 & 0 \\
4 & 7 & 1/16 & 6 & 1 & 1/6 \\
\end{tabular}
\end{center}
gdje je $\displaystyle p_j=\P(X=j)=\frac{1}{2^4}\binom{4}{j} =\frac{3}{2\,j!\,(4-j)!}$.

Dobivamo $\chi^2_q=11/18\approx 0.611$, a uz $f=5-1=4$ stupnja slobode imamo $\chi^2_{4, 0.95} = 9.4877$ pa vrijedi $\chi^2_q < \chi^2_{4, 0.95}$ pa na razini značajnosti od 0.05 **ne možemo odbaciti nul-hipotezu da su svi novčići ispravni**.

U R-u bismo test proveli ovako:
```{r}
xi=0:4
fi = c(5, 26, 34, 24, 7)
probs = dbinom(xi, 4, 0.5)
chisq.test(fi, p=probs)
```
Kako je $p$-vrijednost $0.9618>0.05$ to opet na razini značajnosti $\alpha=0.05$ **ne odbacujemo (već prihvaćamo) nul-hipotezu da su svi novčići ispravni**.


## Zadatak 6.
220 puta bačeno je 5 novčića i blježen je broj $X$ pojavljivanja grbova:
\begin{center}
\begin{tabular}{c|rrrrrr}
$x_j$ & 0 & 1 & 2 & 3 & 4 & 5\\
\hline
$n_j$ & 6 & 32 & 71 & 69 & 35 & 7
\end{tabular}
\end{center}
Pomoću $\chi^2$-testa provjerite hipotezu da $X$ ima binomnu razdiobu s parametrom $p =\frac{1}{2}$ uz nivo značajnosti $\alpha=0.1$.

### Rješenje

Zadatak je posve analogan prethodnome. Sada je $X\sim\bin(5,p_0)$. Za nul-hipotezu uzimamo $\Hn \dots p_0=0.5$, a za dvostranu alternativu $\Ha \dots p_0\neq 0.5$.

Tablica glasi:
\begin{center}
\begin{tabular}{rrrrrr}
$j$ & $n_j$ & $p_j$ & $n\,p_j$ & $\Delta = n_j-n\,p_j$ & $\Delta^2/(n\,p_j)$ \\
\hline
0 & 6 & 1/32 & 6.875 & -0.875 & 0.111 \\
1 & 32 & 5/32 & 34.375 & -2.375 & 0.164 \\
2 & 71 & 10/32 & 68.750 & 2.250 & 0.074 \\
3 & 69 & 10/32 & 68.750 & 0.250 & 0.001 \\
4 & 35 & 5/32 & 34.375 & 0.625 & 0.011 \\
5 & 7 & 1/32 & 6.875 & 0.125 & 0.002 \\
\end{tabular}
\end{center}
gdje je $\displaystyle p_j=\P(X=j)=\frac{1}{2^4}\binom{4}{j} =\frac{3}{2\,j!\,(4-j)!}$.

Dobivamo $\chi^2_q\approx 0.364$, a uz $f=6-1=5$ stupnjeva slobode imamo $\chi^2_{5, 0.9} = 9.236$ pa vrijedi $\chi^2_q < \chi^2_{5, 0.9}$ te na razini značajnosti $\alpha=0.1$ **ne odbacujemo nul-hipotezu da $X$ ima binomnu razdiobu $\bin(5,0.5)$**.

U R-u bismo test proveli ovako:
```{r}
xi=0:5
fi = c(6, 32, 71, 69, 35, 7)
probs = dbinom(xi, 5, 0.5)
chisq.test(fi, p=probs)
```
Kako je $p$-vrijednost $0.9963>0.1$ to na razini značajnosti $\alpha=0.1$ **ne odbacujemo nul-hipotezu da $X$ ima binomnu razdiobu $\bin(5,0.5)$**. Uočimo još da je $p$-vrijednost jako velika što govori o jako dobrom podudaranju podataka s nul-hipotezom (što i dalje ne znači da je nul-hipoteza točna).


# Napomena: ,,Ne odbacujemo $\Hn$'' nasuprot ,,prihvaćamo $\Hn$''

Iako su ove dvije formulacije naizgled logički ekvivalentne, kod statističkog testiranja ipak preferiramo prvu. *Statističkim testom samo možemo odbacivati hipoteze koje nisu u skladu s opažanjima.*

Čitava stvara pomalo podsijeća na dokaz metodom kontradikcije. Prvo pretpostavimo da vrijedi $\Hn$. Zatim logički dobijemo da to vodi na kontradikciju (dobijemo atipičnu vrijednost neke testne statistike, odnosno malu $p$-vrijednost), iz čega zaključujemo da tvrdnja od koje smo krenuli mora biti kriva i zato odbacujemo $\Hn$.

No ukoliko ne dođemo do kontradikcije (ako vrijednost testne statistike nije dovoljno atipična, tj. ako $p$-vrijednost nije mala), to nije dokaz da je $\Hn$ točna. Možda se samo nismo dovoljno potrudili da nađemo kontradikciju. U tom slučaju zapravo ne možemo zaključiti ništa, pa je ispravnije reći da ne isključujemo mogućnost da je $\Hn$ točna, odnosno da ne odbacujemo $\Hn$.

### Primjer.

Pogledajmo još jednom Zadatak 2 u kojem se novčić baca 10000 puta, od kojih je pismo registrirano 5120 puta. Označimo s $p$ vjerojatnost da novčić padne na glavu. Na razini značajnosti $\alpha = 0.05$ napravit ćemo dva testa.
\begin{center}
\begin{tabular}{c||c}
Test 1 & Test 2 \\
\hline
$\Hn\colon \quad p=0.51$ & $\Hn\colon \quad p=0.52$ \\
$\Ha\colon \quad p\neq 0.51$ & $\Ha\colon \quad p\neq 0.52$ \\
\hline
$p\text{-vrijednost} = 0.6965 > \alpha$ & $p\text{-vrijednost} = 0.1093 > \alpha$ \\
ne odbacujemo $\Hn\colon p=0.51$ &  ne odbacujemo $\Hn\colon p=0.52$
\end{tabular}
\end{center}

Uočite da bismo, koristeći drugu formulaciju, rekli da zbog Testa 1 prihvaćamo $p=0.51$ i istovremeno zbog Testa 2 prihvaćamo $p=0.52$, što nema smisla. Točnije je reći da na temelju gornja dva testa uz značajnost $0.05$ ne možemo odbaciti ni $p=0.51$ ni $p=0.52$.

```{r}
xi = c('P', 'G')
fi = c(5120, 4880)
sample = rep(xi, fi)

no_of_succeses = sum(sample == 'P')
n = length(sample)
binom.test(no_of_succeses, n, p=0.51)
binom.test(no_of_succeses, n, p=0.52)
```
\pagebreak


# Dodatak: O intervalima pouzdanosti

Intervali pouzdanosti su intervalni procjenitelji parametara modela.

Pretpostavimo da nam je dan neki konačan uzorak $(x_1,x_2,\dots,x_n)$ za koji pretpostavljamo da predstavlja **$n$ nezavisnih realizacija iste slučajne varijable $X$**.

Primjerice $X$ može biti temperatura zraka, danas u 22 sata, slučajno (uniformno) izabrane lokacije na teritoriju Hrvatske. Ključno je uočiti da ta slučajna varijabla ima dobro definiranu distribuciju, očekivanje, varijancu (disperziju), ... Te parametre bismo mogli točno odrediti ako bismo izmjerili temperaturu u 22 sata za svaku točku teritorija. No radi jednostavnosti mi odredimo nasumce 5 lokacija i pošaljemo petoro meteorologa da provjere temperature u 22 sata, time dobivamo uzorak $(x_1,x_2,\dots,x_5)$.

Iz tog uzorka ne možemo izračunati koja je, primjerice, prava srednja vrijednost temperature nad hrvatskom (matematičko očekivanje od $X$), no srednja vrijednost uzorka $\frac{x_1+x_2+\dots+x_5}{5}$ je dobra točkovna procjena za tu vrijednost. Postavlja se pitanje koliko je dobra ta procjena.

Primjerice, ako se dogodi da smo sve lokacije izabrali nad Velebitom, vjerojatno će naša procjena biti daleko niža od pravog prosjeka. Važno je uočiti da je šansa za to mala ako smo slučajno birali lokacije. Vjerojatnije da će lokacije biti raspoređene svuda po karti.

S tim u vezi definiraju se intervalne procijene. $(1-\alpha)\cdot 100\%$-pouzdan interval za neki parametar od $X$ je zapravo algoritam kojim kreiramo interval iz slučajnog uzorka tako da dobiveni interval u (barem) $(1-\alpha)\cdot 100\%$ slučajeva prekriva pravu vrijednost tog parametra.

Obično se radi jednostavnosti još dodatno pretpostavi da je nepoznata distribucija (u našem slučaju distribucija temperatura $X$) iz neke klase poznatih distribucija parametriziranih nekim parametrima. Na primjer, možda je razumno pretpostaviti da je $X\sim\norm(\mu,\sigma^2)$ za neke $\mu\in\mathbb{R}$ i $\sigma>0$. U tom slučaju 90\% pouzdani interval za $\mu$ je $$\left(\bar{x}-t_{n-1,0.95}\frac{\hat{s}}{\sqrt{n}},\bar{x}+t_{n-1,0.95}\frac{\hat{s}}{\sqrt{n}}\right).$$

Ključno je uočiti da su $\mu$ i $\sigma$ fiksni iako nama nepoznati. Zamislimo sada da u 100 paralelnih svemira s identičnim temperaturama pošaljemo u svakom svemiru naših pet meteorologa da mjere vrijednosti temperature u 22 sata po Hrvatskoj ali u svakom svemiru nezavisno izaberemo 5 lokacija na koje ih šaljemo. Možda smo u nekom svemiru sve poslali na Velebit, ali u većini svemira će ih ipak biti posvuda. I u svakom od svemira izmjerimo pripadni 90\%-pouzdan interval. Time smo dobili 100 različitih (konkretnih, numeričkih) intervala. Interval koji smo dobili iz svemira gdje su svi meteorolozi otišli na Velebit možda neće sadržavati pravu vrijednost $\mu$ no ipak bi u otprilike 90ak svemira dobiveni interval trebao pokrivati konkretan $\mu$. Ta proporcija u koliko posto svemira dobiveni interval zbilja sadrži pravu vrijednost parametra jest upravo što znači pouzdanosti intervala.

Ponekad se kaže da je $p=1-\alpha$ vjerojatnost da parametar koji procjenjujemo ,,upadne'' u taj interval, no trebalo bi biti jasno iz gornje interpretacije da je stvar zapravo obrnuta. $p=1-\alpha$ je vjerojatnost da interval pokrije pravu vrijednost parametra (koja je fiksna iako nama nepoznata). Interval je taj koji je ,,slučajan'' i varira od realizacije do realizacije, od jednog do drugog paralelnog svemira, dok je prava vrijednost parametra fiksna iako nama nepoznata.

Pogledajmo kako ove stvari izgledaju na primjeru. Izgenerirat ćemo 100 uzoraka, svaki od po pet realizacija iz distribucije $\norm(23,4^2)$. Sve realizacije i uzorci su međusobno nezavisini. Zamislite da svakom od stotinu svojih prijatelja date po set od 5 uzoraka i zatražite ih da pogode koji ste $\mu$ koristili za generiranje uzorka. Pri tom im samo kažete da ste uzorak generirali iz jedne normalne distribucije. Svaki od njih na gornji način odredi svoj 90\%-pouzdan interval za $\mu$. Pogledajmo što bi se moglo dogoditi

```{r}
total_in = 0
repetition = 100
df = data.frame(1:5, row.names = 1)
ci_df = data.frame(1:3, row.names = 1)
for (i in 1:repetition) {
  sample = rnorm(5, 23, 4)
  df[i] = sample
  n = length(sample)
  
  mean_est = mean(sample)
  s_est = sqrt(var(sample))
  d = qt(0.95, n - 1) * s_est / sqrt(n)
  is_in = 23 < mean_est + d && 23 > mean_est - d
  
  ci_df[i] = c(mean_est - d, mean_est + d, is_in)
  total_in = total_in + is_in
  
  #print(sample)
  #print(c(mean_est - d, mean_est + d))
  #print(is_in)
}
total_in

library(ggplot2)
qplot(x = 1:repetition, y = 23,
      color = unlist(ci_df[3, ])) + geom_errorbar(aes(
        ymin = unlist(ci_df[1, ]),
        ymax = unlist(ci_df[2, ]), width = 0.15
      ))
```

Na gornjoj slici iscrtali smo intervale pouzdanosti koje je svaki od 100 prijatelja izračunao. Crno su označeni intervali koji ne sadrže vrijednost $\mu=23$. Uočite da je takvih intervala po prilici 10\%.

Uočite još jednu zanimljivu stvar, svaki od naših prijatelja će tvrditi s 90 postotnom sigurnošću da baš njegov interval sadrži pravu vrijednost $\mu$, no otprilike 10 njih od 100 će zapravo biti u krivu (baš zato što su to 90\%-pouzdani intervali).

Analogno, zamislimo sada da uzmemo 100 znanstvenih članaka koji su dokazali svoju hipotezu na razini značajnosti $\alpha = 0.1$ (odnosno s pouzdanošću od 90\%), onda je, kao i gore, skoro pa garantirano da oko 10ak od tih 100 članaka sadrži krive zaključke, čak i ukoliko su znanstvenici koji su ih pisali u potpunosti korektno proveli svoje statističke testove.

# Veza statističkih testova i intervala pouzdanosti

Statistički testovi su usko povezani s intervalima pouzdanosti. Nadovežimo se na gornji primjer. Već spomenutoj stotini svojih prijatelja dali ste po pet nezavisnih uzoraka iz $\norm(23,4^2)$ bez da ste im otkrili koji ste $\mu$ i $\sigma$ koristili za generiranje, no rekli ste im da su podaci došli iz neke normalne razdiobe. Zatim ih zatražite da $t$-testom testiraju hipotezu $\Hn\dots \mu=23$ u odnosu na alternativu $\Ha\dots \mu\neq 23$ na razini značajnosti $\alpha=0.1$.

Svaki od njih će izračunati $T$ statistiku:
$$T = \frac{\bar{x} - 23}{\hat{s}/\sqrt{n}}$$
i provjeriti da li ona upada u kritično područje koje je za dvostrani $t$-test dano s
$$|T|>t_{n-1,1-\alpha/2}\quad \text{tj.} \quad |T|>t_{4,0.95}.$$
U slučaju da upada, oni će odbaciti $\Hn$ a u suprotnom, ako dobiju $|T|\le t_{4,0.95}$, neće odbaciti već prihvatiti $\Hn$. Uočite da vrijedi $|T|\le t_{4,0.95}$ ako i samo ako je $$\bar{x}-t_{n-1,0.95}\frac{\hat{s}}{\sqrt{n}}\le 23 \le \bar{x}+t_{n-1,0.95}\frac{\hat{s}}{\sqrt{n}}.$$
Drugim riječima, točno oni prijatelji čiji 90\%-pouzdani intervali pokrivaju broj 23, sada su dobili da prihvaćaju nul-hipotezu $\mu=23$. Istovremeno, oni prijatelji čiji 90\%-pouzdani interval nije pokrio broj 23, su *(krivo!)* odbacili nul-hipotezu $\mu=23$ u odnosu na alternativu $\mu\neq 23$.

Uočite da je ovdje $\Hn$ bila zbilja ispravna, no oko 90\% prijatelja je počinilo pogrešku prve vrste jer je odbacilio točnu nul-hipotezu.