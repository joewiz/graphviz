(: view samples :)
import module namespace gv = "http://kitwallace.co.uk/ns/graphviz" at "../lib/graphviz.xqm";

declare variable $sampledir := concat($gv:base,"samples/");
declare variable $index := concat($sampledir,"library.xml");

declare option exist:serialize "method=xhtml media-type=application/xhtml+xml";

(:
let $isDba := xmldb:is-admin-user(xmldb:get-current-user())
return
    if (not($isDba)) then
        <div class="warn">
            <p>You have to be a member of the dba group. Please log in using the dashboard and retry.</p>
        </div>
else 
:)
let $login := xmldb:login('/db', 'admin', '')

let $sample := request:get-parameter("sample",())
let $format := request:get-parameter("format","svg")
let $items := doc('/db/apps/graphviz/samples/library.xml')//*:item

return 
<html xmlns ="http://www.w3.org/1999/xhtml">
<body>

      {if (empty($sample))
       then  
         <div>
          <h2>Samples from BASEX ({count($items)})</h2>
          <ul>
          {for $item in $items
           return
           <li> 
                 <a href="?sample={$item/@id}"> {$item/gv:title/string()}</a> &#160;{$item/gv:description/string()}[ {$item/gv:url/@type/string()} ]
           </li>
          }
          </ul>
          <h2>Employee Manager Graph</h2>
          <div>         
               <a href="managers.xq">Graph</a> generated from xml database and linked to employee details
          </div>
         </div>
       else 
          if ($format="svg")
          then
            let $item := $items[@id=$sample]
            let $svg :=
              if ($item/gv:url/@type = "dot")
              then 
                   let $graph := util:binary-to-string(util:binary-doc(concat($sampledir,$item/gv:url)))
                   return gv:dot-to-svg($graph)                   
              else if ($item/gv:url/@type = "dotml")
              then 
                   let $dotml := if (ends-with($item/gv:url, '.xq')) then util:eval(xs:anyURI(concat($sampledir,$item/gv:url))) else doc(concat($sampledir,$item/gv:url))
                   let $graph := gv:dotml-to-dot($dotml)
                   return  
                       gv:dot-to-svg($graph) 
              else()
            return
           <div> 
             {$svg}  
           </div>
         else if ($format="source")
         then 
            let $item := $items[@id=$sample]
            let $source :=
              if ($item/gv:url/@type = "dot")
              then 
                   let $graph := util:binary-to-string(util:binary-doc(concat($sampledir,$item/gv:url)))
                   return <pre>{$graph}</pre>                 
              else if ($item/gv:url/@type = "dotml")
              then 
                   let $dotml := if (ends-with($item/gv:url, '.xq')) then util:eval(xs:anyURI(concat($sampledir,$item/gv:url))) else doc(concat($sampledir,$item/gv:url))
                let $dot := gv:dotml-to-dot($dotml)
                   return  (
                       <pre>{util:serialize($dotml,"method=xml")}</pre>
                       ,
                       <pre>{$dot}</pre>
                   )
              else()
            return
           <div> 
             <h2> 
                Source  {$item/gv:description/string()} [ {$item/gv:url/@type/string()} ] <a href="?sample={$sample}&amp;format=svg">SVG</a>
              </h2>
             {$source}  
           </div>
         else ()
      }
</body>
</html>