# Génère les pages anglaise (en/index.html) et néerlandaise (nl/index.html)
# à partir de index.html (la page française, qui reste la source unique).
#
# Mode d'emploi : modifier index.html (français + attributs data-en / data-nl),
# puis lancer, depuis le dossier du site :
#     powershell -ExecutionPolicy Bypass -File outils/generer-langues.ps1
# Ne JAMAIS modifier à la main en/index.html ou nl/index.html : ils sont réécrits à chaque lancement.

$ErrorActionPreference = "Stop"
$racine = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)
$source = [System.IO.File]::ReadAllText((Join-Path $racine "index.html"), $utf8)
$domaine = "https://lenclos-honfleur.fr"

$langues = @(
    @{
        code = "en"; locale = "en_GB"; alternates = @("fr_FR", "nl_NL")
        title = "L'Enclos | Bistro & wine bar in Honfleur, homemade cooking"
        description = "L'Enclos, family bistro and wine bar in the heart of old Honfleur, 21 rue de la Ville. Homemade cooking, local produce, terrace. Opening hours adapted during school holidays."
        ogDescription = "Family bistro and wine bar in the heart of old Honfleur. Homemade cooking, local produce, terrace and dining room."
        ogTitle = "L'Enclos | Bistro & wine bar in Honfleur"
        ogAlt = "L'Enclos, bistro and wine bar in Honfleur"
        schemaDescription = "Family bistro and wine bar in old Honfleur, run by a father and his son. Homemade cooking made with local produce, terrace and a dining room that can be privatised."
        carteTitle = "Our Menu"
        flagGauche = @{ code = "fr"; href = "../#carte"; label = "Voir la carte en français"; titre = "Voir en français" }
        flagDroite = @{ code = "nl"; href = "../nl/#carte"; label = "Bekijk de kaart in het Nederlands"; titre = "Bekijk in het Nederlands" }
        alts = @{
            "La terrasse de L'Enclos à Honfleur" = "The terrace of L'Enclos in Honfleur"
            "La façade de L'Enclos, bistrot et bar à vin, rue de la Ville à Honfleur" = "The facade of L'Enclos, bistro and wine bar, rue de la Ville in Honfleur"
            "La salle intérieure de L'Enclos, bistrot à Honfleur" = "The dining room of L'Enclos, a bistro in Honfleur"
            "Tartare d'avocat et terrine de porc sur ardoise" = "Avocado tartare and pork terrine on a slate"
            "Tarte normande au caramel et mousse au chocolat" = "Norman tart with caramel and chocolate mousse"
            "Hampe de bœuf sauce échalote et frites" = "Beef skirt with shallot sauce and fries"
            "Instagram de L'Enclos" = "L'Enclos on Instagram"
            "L'Enclos, bistrot et bar à vin" = "L'Enclos, bistro and wine bar"
        }
    },
    @{
        code = "nl"; locale = "nl_NL"; alternates = @("fr_FR", "en_GB")
        title = "L'Enclos | Bistro & wijnbar in Honfleur, huisgemaakte keuken"
        description = "L'Enclos, familiebistro en wijnbar in het hart van het oude Honfleur, 21 rue de la Ville. Huisgemaakte keuken, lokale producten, terras. Aangepaste openingstijden tijdens de schoolvakanties."
        ogDescription = "Familiebistro en wijnbar in het hart van het oude Honfleur. Huisgemaakte keuken, lokale producten, terras en eetzaal."
        ogTitle = "L'Enclos | Bistro & wijnbar in Honfleur"
        ogAlt = "L'Enclos, bistro en wijnbar in Honfleur"
        schemaDescription = "Familiebistro en wijnbar in het oude Honfleur, gerund door een vader en zijn zoon. Huisgemaakte keuken met lokale producten, terras en een zaal die kan worden afgehuurd."
        carteTitle = "Onze Kaart"
        flagGauche = @{ code = "fr"; href = "../#carte"; label = "Voir la carte en français"; titre = "Voir en français" }
        flagDroite = @{ code = "en"; href = "../en/#carte"; label = "View the menu in English"; titre = "View in English" }
        alts = @{
            "La terrasse de L'Enclos à Honfleur" = "Het terras van L'Enclos in Honfleur"
            "La façade de L'Enclos, bistrot et bar à vin, rue de la Ville à Honfleur" = "De gevel van L'Enclos, bistro en wijnbar, Rue de la Ville in Honfleur"
            "La salle intérieure de L'Enclos, bistrot à Honfleur" = "De eetzaal van L'Enclos, een bistro in Honfleur"
            "Tartare d'avocat et terrine de porc sur ardoise" = "Avocadotartaar en varkensterrine op een leisteen"
            "Tarte normande au caramel et mousse au chocolat" = "Normandische taart met karamel en chocolademousse"
            "Hampe de bœuf sauce échalote et frites" = "Runderhanger met sjalotsaus en friet"
            "Instagram de L'Enclos" = "L'Enclos op Instagram"
            "L'Enclos, bistrot et bar à vin" = "L'Enclos, bistro en wijnbar"
        }
    }
)

# élément portant data-en / data-nl : on remplace son contenu par la traduction
$motif = '<(?<tag>[a-z0-9]+)(?<pre>(?:[^>"]|"[^"]*")*?)\sdata-en="(?<en>[^"]*)"(?<post>(?:[^>"]|"[^"]*")*)>(?<inner>.*?)</\k<tag>>'

foreach ($l in $langues) {
    $c = $l.code
    $h = $source

    $evaluateur = {
        param($m)
        $attrs = $m.Groups["pre"].Value + " data-en=`"$($m.Groups['en'].Value)`"" + $m.Groups["post"].Value
        $valeur = $null
        $r = [regex]::Match($attrs, "\sdata-$c=`"([^`"]*)`"")
        if ($r.Success) { $valeur = $r.Groups[1].Value } else { $valeur = $m.Groups["inner"].Value }
        $attrs = [regex]::Replace($attrs, '\sdata-(en|nl)="[^"]*"', "")
        return "<$($m.Groups['tag'].Value)$attrs>$valeur</$($m.Groups['tag'].Value)>"
    }
    $h = [regex]::Replace($h, $motif, $evaluateur, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $h = [regex]::Replace($h, '\sdata-(en|nl)="[^"]*"', "")

    # anglais : prix à l'anglaise (€4.50 au lieu de 4,50 €), uniquement dans le texte visible
    if ($c -eq "en") {
        $h = [regex]::Replace($h, '(<[^>]*>)|([^<]+)', {
            param($m)
            if ($m.Groups[1].Success) { return $m.Value }
            $x = $m.Groups[2].Value
            $x = [regex]::Replace($x, '(\d+),(\d{2})(?:&nbsp;| )€', '€$1.$2')
            $x = [regex]::Replace($x, '(\d+)(?:&nbsp;| )€', '€$1')
            return $x
        })
    }
    # chemins relatifs : les pages sont dans un sous-dossier
    $h = [regex]::Replace($h, '(?<=\s(?:href|src)=")(?!https?:|//|#|mailto:|tel:|data:|\.\./)([^"]*)"', '../$1"')

    # drapeaux : liens vers les deux autres langues
    $g = $l.flagGauche; $d = $l.flagDroite
    $bloc = "<div class=`"carte-header-top`">`n" +
        "                    <a class=`"lang-flag lang-flag-$($g.code)`" href=`"$($g.href)`" hreflang=`"$($g.code)`" lang=`"$($g.code)`" aria-label=`"$($g.label)`" title=`"$($g.titre)`"></a>`n" +
        "                    <h2>$($l.carteTitle)</h2>`n" +
        "                    <a class=`"lang-flag lang-flag-$($d.code)`" href=`"$($d.href)`" hreflang=`"$($d.code)`" lang=`"$($d.code)`" aria-label=`"$($d.label)`" title=`"$($d.titre)`"></a>`n" +
        "                </div>"
    $h = [regex]::Replace($h, '<div class="carte-header-top">.*?</div>', { param($m) $bloc }, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    # en-tête : langue, titre, description, URL, partage
    $url = "$domaine/$c/"
    $h = $h.Replace('<html lang="fr">', "<html lang=`"$c`">")
    $h = [regex]::Replace($h, '<title>.*?</title>', { param($m) "<title>$($l.title)</title>" })
    $h = [regex]::Replace($h, '<meta name="description" content="[^"]*">', { param($m) "<meta name=`"description`" content=`"$($l.description)`">" })
    $h = $h.Replace('<link rel="canonical" href="https://lenclos-honfleur.fr/">', "<link rel=`"canonical`" href=`"$url`">")
    $h = $h.Replace('<meta property="og:url" content="https://lenclos-honfleur.fr/">', "<meta property=`"og:url`" content=`"$url`">")
    $h = [regex]::Replace($h, '<meta property="og:locale" content="fr_FR">\s*<meta property="og:locale:alternate" content="en_GB">\s*<meta property="og:locale:alternate" content="nl_NL">',
        { param($m) "<meta property=`"og:locale`" content=`"$($l.locale)`">`n    <meta property=`"og:locale:alternate`" content=`"$($l.alternates[0])`">`n    <meta property=`"og:locale:alternate`" content=`"$($l.alternates[1])`">" })
    $h = [regex]::Replace($h, '<meta property="og:title" content="[^"]*">', { param($m) "<meta property=`"og:title`" content=`"$($l.ogTitle)`">" })
    $h = [regex]::Replace($h, '<meta property="og:description" content="[^"]*">', { param($m) "<meta property=`"og:description`" content=`"$($l.ogDescription)`">" })
    $h = [regex]::Replace($h, '<meta property="og:image:alt" content="[^"]*">', { param($m) "<meta property=`"og:image:alt`" content=`"$($l.ogAlt)`">" })
    $h = [regex]::Replace($h, '<meta name="twitter:title" content="[^"]*">', { param($m) "<meta name=`"twitter:title`" content=`"$($l.ogTitle)`">" })
    $h = [regex]::Replace($h, '<meta name="twitter:description" content="[^"]*">', { param($m) "<meta name=`"twitter:description`" content=`"$($l.ogDescription)`">" })

    # données structurées : description et lien vers la carte dans la bonne langue
    $h = [regex]::Replace($h, '("description": )"[^"]*"', { param($m) "$($m.Groups[1].Value)`"$($l.schemaDescription)`"" })
    $h = $h.Replace('"hasMenu": "https://lenclos-honfleur.fr/#carte"', "`"hasMenu`": `"$url#carte`"")

    # textes alternatifs et libellés d'accessibilité
    foreach ($k in $l.alts.Keys) { $h = $h.Replace("`"$k`"", "`"$($l.alts[$k])`"") }

    $dossier = Join-Path $racine $c
    New-Item -ItemType Directory -Force $dossier | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $dossier "index.html"), $h, $utf8)
    Write-Host "OK : $c/index.html ($($h.Length) caractères)"
}
