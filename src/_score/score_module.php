<?php
namespace Materia;

class Score_Modules_PrivilegeWalk extends Score_Module
{
	public $allow_distribution = true;

	public function check_answer($log)
	{
		$answers = $this->questions[$log->item_id]->answers;
		foreach($answers as $answer)
		{
			if ($log->text == $answer['text'])
			{
				return $answer['value'];
			}
		}
		return 0;
	}

}
