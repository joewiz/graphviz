xquery version "3.1";

declare function local:describe-successor-relationship($territory-id, $successor-id, $verbose) {
    let $territory := collection('/db/apps/gsh/data/territories/')/territory[id = $territory-id]
    let $successor := collection('/db/apps/gsh/data/territories/')/territory[id = $successor-id]
    let $relationship := $territory//successor[. = $successor-id]/@rel
    return
        if ($relationship = 'split') then
            (: did original country persist after the successor split away? :)
            if ($successor/valid-since lt $territory/valid-until) then
                if ($verbose) then
                    $successor/short-form-name || " split from " || $territory/short-form-name || " in " || $successor/valid-since
                else
                    "split away from in " || $successor/valid-since
            else 
                if ($verbose) then
                    $territory/short-form-name || " split into " || $successor/short-form-name || " in " || $territory/valid-until
                else
                    "split in " || $territory/valid-until
        else if ($relationship = 'independence') then
            if ($verbose) then
                $successor/short-form-name || " became independent from " || $territory/short-form-name || " in " || $successor/valid-since
            else
                "became independent from in " || $successor/valid-since
        else if ($relationship = 'incorporation') then
            if ($verbose) then
                $territory/short-form-name || " was incorporated into " || $successor/short-form-name || " in " || $territory/valid-until
            else
                "was incorporated into in " || $territory/valid-until
        else if ($relationship = 'merger') then
            if ($verbose) then
                $territory/short-form-name || " merged into " || $successor/short-form-name || " in " || $territory/valid-until
            else
                "merged in " || $territory/valid-until
        else
            $relationship || " in " || $territory/valid-until
};

let $lineage-id := request:get-parameter('lineage-id', 42)
let $lineage := collection('/db/apps/gsh/data/lineages')//lineage[current-territory/territory-id = $lineage-id]
let $territories := collection('/db/apps/gsh/data/territories')/territory[id = $lineage//territory-id]
let $default-node-fontsize := attribute fontsize { 10 }
let $default-edge-fontsize := attribute fontsize { 9 }
let $current-territory-fontsize := attribute fontsize { 12 }
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
                if ($territory/exists-on-todays-map = 'true') then $current-territory-fontsize else $default-node-fontsize,
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
                        $default-edge-fontsize
                        ,
                        attribute label { local:describe-successor-relationship($territory/id, $successor, false()) }
                    }
            ,
            (: successors not mentioned in the lineage - need a label to prevent erroneous node labels :)
            for $territory-id in $territory//successor[not(. = $territories/id)]
            let $territory := collection('/db/apps/gsh/data/territories')/territory[id = $territory-id]
            return
                element 
                    { QName("http://www.martin-loetzsch.de/DOTML", "node") }
                    { 
                        attribute id { $territory/id },
                        attribute label { $territory/short-form-name || " (" || $territory/valid-since || "–" || (if ($territory/valid-until = '9999') then 'present' else $territory/valid-until) || ")" },
                        if ($territory/exists-on-todays-map = 'true') then $current-territory-fontsize else $default-node-fontsize,
                        $fontname
                    }
                
        )
return 
    <graph file-name="graphs/nice_graph" rankdir="LR" xmlns="http://www.martin-loetzsch.de/DOTML">
        { $nodes }
        { $edges }
    </graph>
