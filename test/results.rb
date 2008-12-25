DYNAMIC_RESULT = <<EOS
<script type="text/javascript">
swfobject.embedSWF("/swfs/mySwf.swf","mySwf_div","456","123","7","/swfs/expressInstall.swf","flashVar1=value+1+%3E+2&flashVar2=42",{"play": true, "id": "mySwf", "allowscriptaccess": "always"},{"class": "lots", "style": "hot"});
</script>
<div id="mySwf_div">
<a href="http://www.adobe.com/go/getflashplayer">
<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
</a>

</div>
<script type="text/javascript">
swfobject.addDomLoadEvent(function(){Object.extend($('mySwf'), SomeClass.prototype).initialize({"eat": "well", "be": "good"})})
</script>
EOS

STATIC_RESULT = <<EOS
<script type="text/javascript">
swfobject.registerObject("mySwf_container", "7", "/swfs/expressInstall.swf");
</script>
<div id="mySwf_div"><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="456" height="123" id="mySwf_container" class="lots" style="hot">
<param name="movie" value="/swfs/mySwf.swf" />
<param name="play" value="true"/>
<param name="id" value="mySwf"/>
<param name="allowscriptaccess" value="always"/>
<param name="flashvars" value="flashVar1=value+1+%3E+2&flashVar2=42"/>
<!--[if !IE]>-->
<object type="application/x-shockwave-flash" data="/swfs/mySwf.swf" width="456" height="123" id="mySwf">
<param name="play" value="true"/>
<param name="id" value="mySwf"/>
<param name="allowscriptaccess" value="always"/>
<param name="flashvars" value="flashVar1=value+1+%3E+2&flashVar2=42"/>
<!--<![endif]-->
<a href="http://www.adobe.com/go/getflashplayer">
<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
</a>

<!--[if !IE]>-->
</object>
<!--<![endif]-->
</object></div>
<script type="text/javascript">
Object.extend($('mySwf'), SomeClass.prototype).initialize({"eat": "well", "be": "good"})
</script>
EOS