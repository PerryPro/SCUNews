<?php
	
	for($pageNum=1;$pageNum<=2;$pageNum++)
	{
		if($pageNum==1) $url="http://xsc.scu.edu.cn/Website/XG/Home/NewsList?b2RVDmoTL4DLsoJJ-6y0ng==.shtml";//第一页
		else if($pageNum==2) $url="http://xsc.scu.edu.cn/Website/XG/Home/NewsList?APvRSjfI7vuqRRz5liqbWGFA46hwHP4fbgEqqODB8tg=.shtml";//第二页
		else if($pageNum==3) $url="http://xsc.scu.edu.cn/Website/XG/Home/NewsList?nCKhnlEygghm/NoUSjpvHRSG0umVXBCXDEuTqqjQ8VQ=.shtml";//第三页
		else if($pageNum==4) $url="http://xsc.scu.edu.cn/Website/XG/Home/NewsList?79VtbqnEiBVAEx98rBi4lRSG0umVXBCXDEuTqqjQ8VQ=.shtml";//第四页
	$html = file_get_contents($url);
	//echo $html;
	preg_match_all('/<div class="news-list">[\s\S]*?<li>[\s\S]*?<a href="(.*?)"[\s\S]*?>(.*?)<\/a>/',$html,$match);
	//print_r($match);
	$newshtml = $match[0][0];
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
		if(!empty($sarray[$i]))
		{
			$mlink = strchr($sarray[$i],"/Website/");
			$mlink = strchr($mlink,"\" title=",true);
			if(!empty($mlink))
			{
				//echo "http://xsc.scu.edu.cn".$mlink."\n";
				if($outc==0)
				{
					$res=$res."{\"data\": [{\n"."\"link\": \""."http://xsc.scu.edu.cn".$mlink."\",\n";
				}
				else
				{
					$res=$res.",{\n"."\"link\": \""."http://xsc.scu.edu.cn".$mlink."\",\n";
				}
			}
			$mtitle = strchr($sarray[$i],"title=\"");
			$mtitle = substr($mtitle,7);
			$mtitle = strchr($mtitle,"\">",true);
			$mtitle = html_entity_decode($mtitle);
			if(!empty($mtitle))
			{
				//echo $mtitle."\n";
				$res=$res."\"title\": \"".$mtitle."\",\n";
			}
			$mdate = strchr($sarray[$i],"\"date\">");
			$mdate = substr($mdate,7);
			$mdate = strchr($mdate,"</span>",true);
			if(!empty($mdate))
			{
				//echo "2020-".$mdate."\n";
				$res=$res."\"date\": \""."2020-".$mdate."\",\n";
				$res=$res."\"img\": \"http:\/\/47.94.97.113\/newsAPI\/img\/scu.jpg\",\n";
				$res=$res."\"source\": \"学工部\"\n}";
				$outc++;
			}
		}
	}
	$res=$res."]\n}";
	$filepath = $pageNum."\\feed.d.json";
	$myfile = fopen($filepath, "w") or die("Unable to open file!");
	fwrite($myfile, $res);
	fclose($myfile);
	}
?>