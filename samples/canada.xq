xquery version "3.1";

let $lineage-id := request:get-parameter('lineage-id', 42)
let $lineage := collection('/db/apps/gsh/data/lineages')//lineage[current-territory/territory-id = $lineage-id]
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
