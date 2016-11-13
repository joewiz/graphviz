xquery version "3.1";

let $lineage := <lineage>
        <review>
            <status>reviewed</status>
            <reviewer>RasmussenKB</reviewer>
            <reviewed-date>2016-10-31</reviewed-date>
        </review>
        <current-territory>
            <display-name>Canada (1867–present)</display-name>
            <territory-id>42</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/42</url>
        </current-territory>
        <predecessor>
            <display-name>British Columbia (1858–1866)</display-name>
            <territory-id>583</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/583</url>
        </predecessor>
        <predecessor>
            <display-name>Vancouver Island (1849–1866)</display-name>
            <territory-id>582</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/582</url>
        </predecessor>
        <predecessor>
            <display-name>United Province of Canada (1841–1867)</display-name>
            <territory-id>303</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/303</url>
        </predecessor>
        <predecessor>
            <display-name>Upper Canada (1791–1841)</display-name>
            <territory-id>551</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/551</url>
        </predecessor>
        <predecessor>
            <display-name>Lower Canada (1791–1841)</display-name>
            <territory-id>412</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/412</url>
        </predecessor>
        <predecessor>
            <display-name>New Brunswick (1784–1867)</display-name>
            <territory-id>580</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/580</url>
        </predecessor>
        <predecessor>
            <display-name>Cape Breton Island (1784–1820)</display-name>
            <territory-id>579</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/579</url>
        </predecessor>
        <predecessor>
            <display-name>Prince Edward Island (1769–1873)</display-name>
            <territory-id>585</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/585</url>
        </predecessor>
        <predecessor>
            <display-name>Quebec (1763–1791)</display-name>
            <territory-id>467</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/467</url>
        </predecessor>
        <predecessor>
            <display-name>Nova Scotia (1713–1867)</display-name>
            <territory-id>578</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/578</url>
        </predecessor>
        <predecessor>
            <display-name>Newfoundland (1713–1949)</display-name>
            <territory-id>586</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/586</url>
        </predecessor>
        <predecessor>
            <display-name>Rupert's Land (1670–1870)</display-name>
            <territory-id>581</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/581</url>
        </predecessor>
        <predecessor>
            <display-name>British Columbia (1670–1870)</display-name>
            <territory-id>584</territory-id>
            <url>http://localhost:8080/exist/apps/gsh/territories/584</url>
        </predecessor>
    </lineage>
let $territories := collection('/db/apps/gsh/data/territories')/territory[id = $lineage//territory-id]
let $fontsize := attribute fontsize { 9 }
let $fontname := attribute fontname { "Arial" }
let $nodes := 
    for $territory in $territories
    order by $territory/valid-since
    return
        element 
            { QName("http://www.martin-loetzsch.de/DOTML", "node") }
            { 
                attribute id { $territory/id },
                attribute label { $territory/short-form-name || " (" || $territory/valid-since || "–" || (if ($territory/valid-until = '9999') then 'present' else $territory/valid-until) || ")" },
                $fontsize,
                $fontname
            }
let $edges := 
    for $territory in $territories
    return
        (
            (:
            for $predecessor at $n in $territory//predecessor
            return
                element
                    { QName("http://www.martin-loetzsch.de/DOTML", "edge") }
                    {
                        attribute from { $predecessor },
                        attribute to { $territory/id },
                        $fontname,
                        $fontsize
                        ,
                        attribute label { "is predecessor of" }
                        
                    }
            ,
            :)
            for $successor at $n in $territory//successor
            return
                element
                    { QName("http://www.martin-loetzsch.de/DOTML", "edge") }
                    {
                        attribute from { $territory/id },
                        attribute to { $successor },
                        $fontname,
                        $fontsize
                        ,
                        attribute label { "in " || $territory/valid-until }
                    }
        )
return 
    <graph file-name="graphs/nice_graph" rankdir="LR" xmlns="http://www.martin-loetzsch.de/DOTML">
        { $nodes }
        { $edges }
    </graph>
