<?
include 'class_Item.php';
$cs = $S->cur_sect;
try 
{
  if ($_POST && $USER->id())
	{
		$__item = $DB->selectData("select id, istatus, user_id from {$cs} where id = ".(int)$S->vars[$cs]);
		if (!$__item) Entry::loadError(404);
		
		if ($_POST['message'] && $_POST['to_id'])
			$USER->sendMessage($_POST, $__item['id'], $cs == 'orders' ? T_ORDER : T_VACANCY);
		if ($_POST['response'])
			$USER->leaveResponse($_POST, $__item['id'], $cs);
	}
	elseif ($USER->hold() && $S->vars['pay'])
	{
		$USER->payCommission($S->vars[$cs], $cs);
	}
}
catch (UserError $e) {}

if ($_POST || $S->vars['pay']) $E->reloadPage(Sets::URL.$cs.'/'.$S->vars[$cs]);

$item = new Item($S->vars[$cs], $cs);
$arch = $item->data['istatus'] != ST_OPN;

$page->setVar('is_archive', $arch);


$page->setVar('ctg_filter', Info::getCtgList($cs, "{$cs}.checked = 1 and {$cs}.istatus ".($arch ? "!= " : "= ").ST_OPN));

$page->setPagePart('LeftColumn', 'items_ctgfilter');

$page->setVar('istatus', $item->data['istatus']);
$page->setVar('offers', $item->getOffers());
$page->setVar('mod_cs', $ADMIN->r($cs));
$page->setVar('canPostOffer', $item->canPostOffer());
$page->setVar('canEditOffer', $item->canEditOffer());
$page->setVar('canAcceptOffer', $item->canAcceptOffer());
$page->setVar('item', $item->data);
$page->setPageTitle($item->data['title'], true);
$page->setPagePart('Content', 'items_item');
$digits = Info::userDigits($USER->id());
	$page->setVar('kk_resp_pos', (int)$digits[0]);
	$page->setVar('kk_resp_neg', (int)$digits[1]);
	
if ($item->canPostOffer() || $item->canEditOffer() || $item->canAcceptOffer() || $ADMIN->r($cs))
{
	$page->addHLink('{%sys:js%}ajax.js', 'js');
	$page->addHLink('{%sys:js%}offers.js', 'js');
}

if ($USER->id() == $item->data['user_id'])
	$page->setPagePart('Message', 'form_message');

if (!$item->data['emp_resp'] && ($item->data['istatus'] == ST_WRK && $USER->id() == $item->data['user_id']) || ($item->data['istatus'] == ST_FIN && $USER->id() == $item->data['accepted']['user_id']))
	$page->setPagePart('Response', 'form_response');
	
if ($ADMIN->r($cs))
	$page->setConst('aroot', $S->root.Sets::ADMIN_DIR.'/');
	
if (!$item->data['checked'])
	$E->Error($cs.'IsUnchecked');
?>
