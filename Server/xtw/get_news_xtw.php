<?php
	//exec("C:\\Python\\python.exe get_html_xtw.py");
	$pageNum = 1;
	$newshtml = file_get_contents("data1.html"); 
	$sarray = array();
	//echo $newshtml;
	$sarray = explode("\n",$newshtml);
	$res = "";//输出的json字符串
	$c = count($sarray);
	$outc = 0;//输出json的计数器
	for($i=0;$i<$c;$i++)
	{
		$sarray[$i] = ltrim($sarray[$i]);
		//echo $sarray[$i]."\n";
		$sarray[$i] = strchr($sarray[$i],"<li class=\"hvr-underline-from-left\"");
		if(!empty($sarray[$i]))
		{
			$mlink = strchr($sarray[$i],"/info/");
			$mlink = strchr($mlink,"\" target=",true);
			if(!empty($mlink))
			{
				//echo "http://tuanwei.scu.edu.cn".$mlink."\n";
				if($outc==0)
				{
					$res=$res."{\"data\": [{\n"."\"link\": \""."http://tuanwei.scu.edu.cn".$mlink."\",\n";
				}
				else
				{
					$res=$res.",{\n"."\"link\": \""."http://tuanwei.scu.edu.cn".$mlink."\",\n";
				}
			}
			$mtitle = strchr($sarray[$i],"title=\"");
			$mtitle = substr($mtitle,7);
			$mtitle = strchr($mtitle,"\" href=",true);
			$mtitle = html_entity_decode($mtitle);
			if(!empty($mtitle))
			{
				//echo $mtitle."\n";
				$res=$res."\"title\": \"".$mtitle."\",\n";
			}
			$mdate = strchr($sarray[$i],"<time>");
			$mdate = substr($mdate,6);
			$mdate = strchr($mdate,"</time>",true);
			if(!empty($mdate))
			{
				//echo $mdate."\n";
				$res=$res."\"date\": \"".$mdate."\",\n";
				$res=$res."\"img\": \"http:\/\/47.94.97.113\/newsAPI\/img\/scu.jpg\",\n";
				$res=$res."\"source\": \"校团委\"\n}";
				$outc++;
			}
		}
	}
	
	$res=$res."]\n}";
	$filepath = $pageNum."\\feed.d.json";
	$myfile = fopen($filepath, "w") or die("Unable to open file!");
	fwrite($myfile, $res);
	fclose($myfile);
	
?>