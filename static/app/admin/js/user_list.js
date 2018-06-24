var UserList = (function(){
	return {
		init: function(){
			this.event();
		},

		event: function(){
			// Модальное окно подтверждения удаления пользователя
			$('#user-delete-modal').on('show.bs.modal',function(e){
				var modal = $(this);
				var btn = $(e.relatedTarget);
				modal.find('.modal-title').text('Подтверждение на удаление пользователя');
				modal.find('.modal-body p').text('Вы действительно хотите удалить пользователя '+btn.data('username')+'?');
				modal.find('.modal-footer a').attr('href', '/admin/users/'+btn.data('id')+'/delete/');
			});
		},

		showError: function(){
			
		}
	};
})();

UserList.init();
