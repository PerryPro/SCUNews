<?php
	//exec("C:\\Python\\python.exe get_html_xtw.py");
	$pageNum = 1;
	$newshtml = file_get_contents("http://jwc.scu.edu.cn/index.htm"); 
	$sarray = array();
	//echo $newshtml;
	$sarray = explode("\n",$newshtml);//分割为数组，每行为一个数组元素
	$flag = 0;
	$res = "";//输出的json字符串
	$c = count($sarray);
	$outc = 0;//输出json的计数器
	$Ttitle = "";
	for($i=0;$i<$c;$i++)
	{
		$sarray[$i] = ltrim($sarray[$i]);
		//echo $sarray[$i]."\n";
		//$sarray[$i] = strchr($sarray[$i],"<li class=\"hvr-underline-from-left\"");
		if(strpos($sarray[$i],"<div class=\"list-llb-box\">") !== false)
		{
			$flag =1;
			continue;
		}
		if(strpos($sarray[$i],"<script>_showDynClickBatch") !== false)
		{
			$flag =0;
			break;
		}
		if($flag == 1)
		{
		$zd = 0;
		if(!empty($sarray[$i]))
		{
			if(strpos($sarray[$i],"<em style=\"font-style: normal;color:#bc0102\">") !== false)
			{
				$Ttitle = "【置顶】".$Ttitle;
			}
			$mlink = strchr($sarray[$i],"info/");
			$mlink = strchr($mlink,"\" target=",true);
			if(!empty($mlink))
			{
				//echo "http://jwc.scu.edu.cn/".$mlink."\n";
				if($outc==0)
				{
					$res=$res."{\"data\": [{\n"."\"link\": \""."http://jwc.scu.edu.cn/".$mlink."\",\n";
				}
				else
				{
					$res=$res.",{\n"."\"link\": \""."http://jwc.scu.edu.cn/".$mlink."\",\n";
				}
			}
			$mtitle = strchr($sarray[$i],"title=\"");
			$mtitle = substr($mtitle,7);
			$mtitle = strchr($mtitle,"\">",true);
			$mtitle = html_entity_decode($mtitle);
			if(!empty($mtitle))
			{
				$Ttitle = $mtitle;
				//echo $mtitle."\n";
				//$res=$res."\"title\": \"".$mtitle."\",\n";
			}
			$mdate = strchr($sarray[$i],"<em class=\"fr list-date-a\">[");
			$mdate = substr($mdate,28);
			$mdate = strchr($mdate,"]</em>",true);
			if(!empty($mdate))
			{
				
				if(!empty($Ttitle))
				{
					//echo $Ttitle."\n";
					$res=$res."\"title\": \"".$Ttitle."\",\n";
					$Ttitle = "";
				}
				//echo $mdate."\n";
				$res=$res."\"date\": \"".$mdate."\",\n";
				$res=$res."\"img\": \"http:\/\/47.94.97.113\/newsAPI\/img\/scu.jpg\",\n";
				$res=$res."\"source\": \"教务处\"\n}";
				$outc++;
			}
			}
		}
	}
	
	$res=$res."]\n}";
	$filepath = $pageNum."\\feed.d.json";
	$myfile = fopen($filepath, "w") or die("Unable to open file!");
	fwrite($myfile, $res);
	fclose($myfile);
	
?>