<?php
class Task extends CI_Controller {

  public function __construct() {
    parent::__construct();
    $this->load->helper('url');
  }

	public function create($list_id)
	{
    $user_id = $this->session->userdata('user_id');
    $list = new List_model($list_id);
    if(!$list->exists()) {
      redirect('/tasklist/viewall');
      return;
    }
    if($user_id !== False) {
      $user = new User_model($user_id);
      if($list->owner_id != $user_id && !$list->shared_with($user_id)) {
        redirect('/tasklist/viewall');
        return;
      }
    } else {
      redirect('/authentication/signin/');
      return;
    }
    if($this->input->post('text') !== False) {
      $task = new Task_model();
      $task->text = $this->input->post('text');
      $list = new List_model($list_id);
      if($task->save(array('list'=>$list))) {
        redirect("/tasklist/view/$list_id");
      } else {
        echo 'Task not saved';
      }
    } else {
      $data["list_id"] = $list_id;
      $data["title"] = 'New task';
      $data['username'] = $user->username;
      $this->load->view('header', $data);
      $this->load->view('task_create', $data);
    }
	}

	public function delete($task_id)
	{
    $user_id = $this->session->userdata('user_id');
    $task = new Task_model($task_id);
    if(!$task->exists()) {
      redirect('/tasklist/viewall');
      return;
    }
    $list = new List_model($task->list_id);
    if($user_id !== False) {
      if($list->owner_id != $user_id && !$list->shared_with($user_id)) {
        redirect('/tasklist/viewall');
        return;
      }
    } else {
      redirect('/authentication/signin/');
      return;
    }
    $task->delete();
    redirect('/tasklist/view/'.$list->id);
	}

	public function edit($task_id)
	{
    $user_id = $this->session->userdata('user_id');
    $task = new Task_model($task_id);
    if(!$task->exists()) {
      redirect('/tasklist/viewall');
      return;
    }
    $list = new List_model($task->list_id);
    if($user_id !== False) {
      $user = new User_model($user_id);
      if($list->owner_id != $user_id && !$list->shared_with($user_id)) {
        redirect('/tasklist/viewall');
        return;
      }
    } else {
      redirect('/authentication/signin/');
      return;
    }
    if($this->input->post('text') !== False) {
      $task->text = $this->input->post('text');
      if($task->save()) {
        $task->list->get();
        redirect("/tasklist/view/".$task->list->id);
      } else {
        echo 'Task not saved';
      }
    } else {
      $data["task_id"] = $task_id;
      $data["text"] = $task->text;
      $data["title"] = 'Edit task';
      $data["username"] = $user->username;
      $this->load->view('header', $data);
      $this->load->view('task_edit', $data);
    }

	}
	//Marks a certain task as done
	public function mark_done($taskID)
	{
    $user_id = $this->session->userdata('user_id');
    $task = new Task_model($taskID);
    if(!$task->exists()) {
      redirect('/tasklist/viewall');
      return;
    }
    $list = new List_model($task->list_id);
    if($user_id !== False) {
      if($list->owner_id != $user_id && !$list->shared_with($user_id)) {
        redirect('/tasklist/viewall');
        return;
      }
    } else {
      redirect('/authentication/signin/');
      return;
    }
		if($task->done == 0)
		{
			$task->done = 1;
			$task->save();
		}else{
      $task->done = 0;
      $task->save();
    }
    redirect('/tasklist/view/'.$list->id);
	}
}
?>

