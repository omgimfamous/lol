<?
class Item
{
  public $id = null;	
	public $data = null;	
	public $offers = null;
    
	protected $cs = null;
	protected $rPostOffer = null;
	protected $rEditOffer = null;
	protected $rAcceptOffer = null;
	
	
		
			
			
		
			
				
			
			

	
	public function __construct ($id, $cs)
	{
		global $E, $DB, $USER, $ADMIN;
		
		$this->cs = $cs;
		
		$this->data = $DB->selectData("select 
		{$cs}.*, users.login, users.userpic, users.master, users.lastname, users.firstname,
		if(now() < users.lastvisit + interval ".Sets::USER_TIMEOUT." minute, 1, 0) as online,
		datediff(curdate(), users.reg_date) as in_service,
		ctg_{$cs}.name as category,
		(select count(*) from {$cs}_offers where item_id = {$cs}.id and ".
		($USER->id() ? 'dt >= "'.$USER->get('lastvisit').'"' : 'date(dt) >= curdate()').") as cmm_new,
		if((select 1 from responses where to_id = {$cs}.user_id and theme_id = {$cs}.id and theme_type = ".($cs == 'orders' ? T_ORDER : T_VACANCY)."),1,0) as emp_resp, {$cs}.dt + interval {$cs}.days day as dt_end,
		if ({$cs}.dt <= subdate(now(),{$cs}.days),1,0) as time_out, users_files.url
		from {$cs} 
		left join users_files on (users_files.type_id = {$cs}.id and users_files.type = ".($cs == 'orders' ? T_ORDER : T_VACANCY)." and users_files.user_id = {$cs}.user_id), ctg_{$cs}, users 
		where {$cs}.user_id = users.id and ctg_{$cs}.id = {$cs}.ctg_id and {$cs}.id = {$id}", DBC::AS_VECTOR, array('dt_view' => ST::DT_SIMPLE));
		
		if (!$this->data || (!$this->data['checked'] && !$ADMIN->r($cs) && $USER->id() != $this->data['user_id']))
			Entry::loadError(404);
		
		$this->data['in_service'] = ST::daysInService($this->data['in_service']);
		$this->id = $this->data['id'];
		
		if ($this->data['country_id']) $loc = array($this->data['country_id'], T_COUNTRY);
		if ($loc && $this->data['region_id']) $loc = array($this->data['region_id'], T_REGION);
		if ($loc && $this->data['city_id']) $loc = array($this->data['city_id'], T_CITY);
		
		if ($loc) $this->data['location'] = $DB->selectData("select name from locations where id = {$loc[0]} and tp = {$loc[1]}");
		
		if ($this->data['time_out'] && $this->data['istatus'] == ST_OPN)
		{
			$this->data['istatus'] = ST_CLS;
			$DB->updateData($this->cs, 'istatus = '.ST_CLS, 'id = '.$this->id);
		}
		
		if ($USER->id() != $this->data['user_id'])
			Entry::updStatistics($cs, $this->id);
	}
	
	public function getOffers ($filter = false)
	{
		global $DB;
		
		if ($this->offers !== null)
			return $this->offers;
		
		$this->offers = $DB->selectData("select 
			{$this->cs}_offers.id, {$this->cs}_offers.dt, {$this->cs}_offers.accepted,
			{$this->cs}_offers.price, {$this->cs}_offers.comment,".
			($this->cs == 'orders' ? $this->cs.'_offers.period as `period`, ' : '')."
			users.id as user_id, users.login, users.master,
			if(now() < users.lastvisit + interval ".Sets::USER_TIMEOUT." minute, 1, 0) as online,
			datediff(curdate(), users.reg_date) as in_service,
			(select count(*) from responses where to_id = users.id and bias = -1) as r_neg_cnt,
						(select count(*) from responses where to_id = users.id and bias = 1) as r_pos_cnt,

			users.lastvisit, users.userpic, users.exp_rating, users.lastname, users.firstname
			from {$this->cs}_offers left join users on ({$this->cs}_offers.user_id = users.id)
			where {$this->cs}_offers.item_id = ".$this->data['id'].' order by dt desc', DBC::AS_MATRIX, true);
				
				print_r($this->offers);
		if ($this->offers) foreach ($this->offers as &$o) if ($o['accepted'] == 1)
		{
			$this->data['accepted'] = &$o;
			$this->data['user_exp'] = $o['login'];
			break;
		}
		
		return $this->offers;
	}
	
	public function canPostOffer ()
	{
		if ($this->rPostOffer === null)
		{
			global $USER, $ADMIN;
			
			$u = $USER->id() && !$USER->hold() && $this->data['user_id'] != $USER->id() && $this->data['istatus'] == ST_OPN;
			$this->rPostOffer = $u && $this->data['checked'] && $this->data['onlymaster'] <= $USER->get('master');
			
			if ($this->rPostOffer === true && $this->offers) foreach ($this->offers as $cmm)
				if ($cmm['user_id'] == $USER->id())
				{
					$this->rPostOffer = false;
					$this->rEditOffer = true;
					break;
				}
				
			$this->rEditOffer = ($ADMIN->r($this->cs) && $this->offers ? true : ($u && (bool)$this->rEditOffer));
		}
		return $this->rPostOffer;
	}
	
	public function canEditOffer ()
	{
		if ($this->rEditOffer === null)
			$this->canPostOffer();
			
		return $this->rEditOffer;
	}
	
	public function canAcceptOffer ()
	{
		if ($this->rAcceptOffer === null)
		{
			global $USER;
			$this->rAcceptOffer = $this->data['user_id'] == $USER->id() && !$USER->hold() && $this->data['istatus'] == ST_OPN && $this->data['checked'];
		}
		return $this->rAcceptOffer;
	}
}

?>
