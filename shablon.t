<?
$ISORD = $cur_sect == 'orders';
?>
<div class="rc ilist ind">
  <div class="hitem">
		<h2<?=($item['onlymaster'] ? ' class="pro"' : '')?>>{%pagetitle%}</h2>
		<p class="i_ctg"><?=($item['category'] ? $item['category'] : 'Категория не указана')?></p>
		<b><?=$item['location']?></b>
	</div>
	<div class="idetails">
<tr><th rowspan="3" valign="top"><img class="upic" src="<?=($item['userpic'] ? '{%root%}'.Sets::DIR_USERPICS.$item['userpic'] : '{%sys:img%}userpic_big.gif')?>" alt="<?=$item['login']?>" /></th>
		
		<table>
			<td class="first"><div class="useronline"><a href="{%root%}users/<?=$item['login']?>/" class="<?=($item['master'] ? 'pro ' : '').($item['online'] ? 'on' : 'off')?>line"><i></i><?=$item['login']?>&nbsp;[<?=$item['lastname']?>&nbsp;<?=$item['firstname']?>]</a></div>в сервисе <?=$item['in_service']?></td></tr>
	
<tr><td>
<? 
if ($ISORD) {
	$modes = array(PAY_EXP=>'Способ оплаты на выбор исполнителя',PAY_CASH=>'Наличный расчет',PAY_NONCSH=>'Безналичный расчет',PAY_WEB=>'Электронные системы');
} else {
	$modes = array(VAC_OFFICE=>'Работа в офисе',VAC_REMOTE=>'Удаленная работа');
}
echo ($ISORD ? '<b>Бюджет</b>' : '<b>Оклад</b>').'<b>:</b> <b><font color="#D12027">'.($item['payment']).'&nbsp;USD</b></font> <span>('.$modes[$item[$ISORD ? 'payway' : 'mode']].')</span>';
?>
</td></tr>
<tr><td><?	
if ($ISORD) switch ($istatus)
{

	case ST_OPN: ?><b>Проект открыт:&nbsp;</b><?=$item['dt'].' &mdash; '.$item['dt_end']; break;
	case ST_WRK: ?><b>Проект исполняется пользователем <a href="{%root%}users/<?=$item['user_exp']?>/"><?=$item['user_exp']?></a></b><? break;
	case ST_FIN: ?><b>Проект выполнен пользователем <a href="{%root%}users/<?=$item['user_exp']?>/"><?=$item['user_exp']?></a></b><?;
		if (!$item['emp_resp'] && $kk_id == $item['accepted']['user_id']) {?> | <a href="#" onclick="Blocks.show('resp_form'); return false;">Написать отзыв заказчику</a><?} break;
	case ST_CLS: ?><b>Проект закрыт</b><? break;
}
else switch ($istatus)
{
	case ST_OPN: ?><b>Вакансия открыта:</b> с <?=$item['dt'].' по '.$item['dt_end']; break;
	case ST_FIN: ?><b>На должность нанят пользователь <a href="{%root%}users/<?=$item['user_exp']?>/"><?=$item['user_exp']?></a></b><?;
		if (!$item['emp_resp'] && $kk_id == $item['accepted']['user_id']) {?> | <a href="#" onclick="Blocks.show('resp_form'); return false;">Написать отзыв заказчику</a><?} break;
	case ST_CLS: ?><b>Вакансия закрыта</b><? break;
}

if (!$mod_cs && $kk_id == $item['user_id'] && $istatus == ST_OPN) {?>
	<div class="edit"><a href="{%root%}account/<?=$cur_sect.'/'.$item['id']?>/" title="Редактировать"><img src="{%sys:img%}icon_edit.gif" /></a><a href="{%root%}account/<?=$cur_sect.'/del/'.$item['id']?>/" title="Удалить" onclick="return confirm('Вы действительно хотите удалить <?=($ISORD ? 'этот заказ' : 'эту вакансию')?>?');"><img src="{%sys:img%}icon_del.gif" /></a></div>
<?} elseif ($kk_hold && isset($kk_hold[$ISORD ? T_ORDER : T_VACANCY][$item['id']])) 
{?>&nbsp;|&nbsp;<a href="{%root%}<?=$cur_sect.'/'.$item['id']?>/pay/">Оплатить коммиссию</a><?
} if ($mod_cs) {?>
<div class="edit">
	<a href="{%aroot%}<?=$cur_sect.'/id-'.$item['id']?>/" title="Редактировать"><img src="{%sys:img%}icon_edit.gif" /></a>
	<a href="#" title="Удалить" onclick="if (confirm('Вы действительно хотите удалить эту запись?')) document.fdel.submit(); return false;"><img src="{%sys:img%}icon_del.gif" /></a>
<? if (!$item['checked']) {?>
	<form>
		<input type="checkbox" name="itemid" id="chkitem<?=$item['id']?>" value="<?=$item['id']?>" style="vertical-align: text-top;" />
		<label for="chkitem<?=$item['id']?>">Проверено</label>
	</form>
</div>
<script type="text/javascript">
var itemChecker = X.$('chkitem<?=$item['id']?>');
itemChecker.onclick = function() {
	ajax.send({url: 'checkitem.php', method: 'get', data: 'e=1&checked='+(this.checked ? 1 : 0)+'&itemid='+this.value+'&to=<?=$cur_sect?>', 
		start: function(){Blocks.addClass('loader', 'loading')},
		ready: function(rt){
			Blocks.removeClass('loader', 'loading');
			if (rt) X.$('sysmssgs').innerHTML = rt;
		},
		error: function(){
			Blocks.removeClass('loader', 'loading');
			itemChecker.checked = itemChecker.defaultChecked;
			ajax.defaultError();
		}
	});
}
</script>
<?} else echo "</div>\n";?>
<form name="fdel" action="{%aroot%}<?=$cur_sect?>/" method="post"><input type="hidden" name="delid" value="<?=$item['id']?>" /></form>
<?}?></td></tr>

			<tr><td><b>Предложения:</b> <span id="offnum"><?=($offers ? count($offers) : 0); if ($item['cmm_new']) {?> <span>(+<?=$item['cmm_new']?>)</span><?}?></span>&nbsp;&nbsp;|&nbsp;&nbsp;<b>Просмотры:</b> <?=$item['hits'].' ('.$item['hosts'].ST::wEnding($item['hosts'], ' уникальный', ' уникальных')?>)</td>
</tr>


		</table>
		<td><p><?=$item['description']?></p></tr><? 
if ($item['phone'] && $kk_id && ($kk_id == $item['accepted']['user_id'] || $kk_id == $item['user_id'])) {
	?><p class="phone">Телефон для связи: <b><?=$item['phone']?></b></p><?}
if ($item['url']) {
	?><p class="attach">Прикрепленный файл: <a href="{%root%}<?=Sets::DIR_USERFILES.$item['url'].'">'.basename($item['url'])?></a></p><?}?>
	</div>
<!-- Response -->
<!-- Message -->

		
<div class="ioffers"><? if ($canPostOffer) {?>
		<div class="hadd_offer" id="a_req"><b><a href="#" onclick="Blocks.show('foffer'); Blocks.hide('a_req'); return false;">Добавить предложение</a></b></div>
<?}?>
<span id="sysmssgs">
<!-- SysMsg -->
</span>
		<h2>Предложения <?=($ISORD ? 'исполнителей' : 'соискателей')?><span id="loader">&nbsp;</span></h2>
<? if ($canPostOffer || $canEditOffer) {?>
<form name="foffer" class="feditor" id="foffer" action="{%self%}" method="post" style="display: none;">
<div class="close" onclick="drop_form(); Blocks.show('a_req');" title="Закрыть"></div>
<div class="d">
	<fieldset id="iprice" class="fl">
		<label for="iiprice">Сумма</label>
		<input type="text" name="price" id="iiprice" class="in" maxlength="10" />
	</fieldset><? if ($ISORD) {?>
	<fieldset id="iperiod" class="fl">
		<label for="iiperiod">Сроки</label>
		<input type="text" name="period" id="iiperiod" class="in" maxlength="25" />
	</fieldset><?}?>
	<div class="clear"></div>
	<fieldset id="icomment">
		<label for="iicomment">Комментарий</label>
		<textarea name="comment" class="in" id="iicomment"></textarea><br />
		Осталось символов: <span id="cmm_len"></span>
	</fieldset>
	<fieldset>
		<input type="hidden" name="user_id" value="<?=$kk_id?>" />
		<div class="btn"><b><i><input type="submit" value="Отправить" /></i></b></div>
		<div class="clear"></div>
	</fieldset>
</div>
</form>
<?} if ($canPostOffer || $canEditOffer || $canAcceptOffer) {?>
<script type="text/javascript">
var offer_to = <?=($ISORD ? T_ORDER : T_VACANCY)?>;
var offer_act = 'add';
var item_id = <?=$item['id']?>;

var T_ORDER = <?=T_ORDER?>;
var T_VACANCY = <?=T_VACANCY?>;

<? if ($canPostOffer || $canEditOffer) {?>
var f_offer = new preSubmit(document.foffer, 2, sendOffer);
	f_offer.add('price', {required: false, check: /^[\d]+$/, dynamic: true, markBlock: 'i%%'});<? if ($ISORD) {?>
	f_offer.add('period', {required: false, check: 1, dynamic: true, markBlock: 'i%%'});<?}?>
	f_offer.add('comment', {check: 1, lenMax: 500, lenBlock: 'cmm_len', dynamic: true, markBlock: 'i%%'});
<?}?>
</script>
<?}?>
		<table class="ttab">
			<tr>
				<th class="c_user">Пользователь</th><? if ($ISORD) {?>
				<th class="c_price">Цена</th>
				<th class="c_date">Сроки</th><?} else {?>
				<th class="c_price">Оклад</th><?}?>
				<th class="c_date">Дата</th>
			</tr>
		</table>
		<div id="offers_list">
<? if ($offers) foreach ($offers as $cmm) {?>
		<table class="ttab" id="u_offer<?=$cmm['id']?>">
			<tr>
				<td class="c_user">
					<img class="upic" src="<?=($cmm['userpic'] ? '{%root%}'.Sets::DIR_USERPICS.'small/'.$cmm['userpic'] : '{%sys:img%}userpic_sm.gif')?>" alt="<?=$cmm['login']?>" />
					<div class="fl">
						<div class="useronline"><a href="{%root%}users/<?=$cmm['login']?>/" class="<?=($cmm['master'] ? 'pro ' : '').($cmm['online'] ? 'on' : 'off')?>line"><i></i><?=$cmm['login']?> [<?=$cmm['lastname']?>&nbsp;<?=$cmm['firstname']?>]</a></div>
						<div class="rating"><div style="width: <?=ST::stars($cmm['exp_rating'], 54)?>px;"></div><small>Рейтинг:&nbsp;<?=$cmm['exp_rating']?><br>в сервисе: <?=ST::daysInService($cmm['in_service'])?></small></div>
						<b class="pos"><?=$kk_resp_pos.'</b> / <b class="neg">'.$kk_resp_neg?></b><br />
					</div>
				</td>
				<td class="c_price" id="p_offer<?=$cmm['id']?>"><?=ST::cMoney($cmm['price'])?></td><? if ($ISORD) {?>
				<td class="c_date" id="d_offer<?=$cmm['id']?>"><?=$cmm['period']?></td><?}?>
				<td class="c_date"><?=$cmm['dt']?></td>
			</tr>
			<tr><td colspan="<?=($ISORD ? 4 : 3)?>" class="c_text" id="c_offer<?=$cmm['id']?>"><?=$cmm['comment']?></td></tr>
			<tr><td colspan="<?=($ISORD ? 4 : 3)?>" class="c_footer"><a href="{%root%}users/<?=$cmm['login']?>/portfolio/">Портфолио</a><?if ($item['user_id'] == $kk_id) {?><b>|</b><a href="#" onclick="document.pmessage.to_id.value = <?=$cmm['user_id']?>; X.$('pmsg_to').innerHTML = '<?=$cmm['login']?>'; if (X.$('resp_form')) {Blocks.hide('resp_form');} Blocks.show('msg_form'); return false;">Написать приватное сообщение</a><?} if ($item['istatus'] == ST_WRK && $item['accepted'] == $cmm && $item['user_id'] == $kk_id) {?><b>|</b><a href="#" onclick="Blocks.hide('msg_form'); Blocks.show('resp_form'); return false;">Написать отзыв</a><?} if ($canAcceptOffer) {?><b>|</b><a href="#" onclick="return acceptOffer(<?=$cmm['id'].", '{$cmm['login']}', this"?>);"><?=($ISORD ? 'Назначить исполнителем' : 'Нанять')?></a><?} if ($mod_cs || $canEditOffer && $cmm['user_id'] == $kk_id) {?><b>|</b><a href="#" onclick="return getOffer(<?=$cmm['id']?>);">Редактировать</a><b>|</b><a href="#" onclick="return delOffer(<?=$cmm['id']?>);">Удалить</a><?}?></td></tr>
		</table>
<?}?>
		</div>
	</div>
	<div class="crn_b"><b></b><i></i></div>
</div>
</div>
