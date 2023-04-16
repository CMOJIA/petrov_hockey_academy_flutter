String getProfileData = '''
query {
  clientSpace {
    me {
      phone,
      email,
      avatar {
        filename
      }
      is_redactor
      client {
        first_name,
        middle_name,
        last_name,
      }
    }
  }
}
''';

String setFirstName = r'''
mutation SetFirstName($firstName: String!) {
  setFirstName(first_name: $firstName)
}
''';

String setMiddleName = r'''
mutation SetMiddleName($middleName: String!) {
  setMiddleName(middle_name: $middleName)
}
''';

String setLastName = r'''
mutation SetLastName($lastName: String!) {
  setLastName(last_name: $lastName)
}
''';

String setPhoneNumber = r'''
mutation SetPhone($phone: String!) {
  setPhone(phone: $phone)
}
''';

String setEmail = r'''
mutation SetEmail($email: String!) {
  setEmail(email: $email)
}
''';

String setPassword = r'''
mutation SetPassword($password: String!) {
  setPassword(password: $password)
}
''';

String setAvatar = r'''
mutation SetAvatar($file: Upload!) {
  setAvatar(file: $file)
}
''';

String getAvatar = '''
query {
  clientSpace{
    me {
      avatar{
        filename
      }
    }
  }
}
''';

String getAlbums = r'''
query GetAlbums($page: Int){ 
  clientSpace{
    album(page: $page, orderBy: {field: "album_id", order: DESC}){
      data{
        title,
        author,
        group{
          title
        },
        photos{
          image
        },
        path,
        is_public,
        published_dt,
      }
    }
	}
}''';

String getVideos = r'''
query GetVideos($page: Int){ 
  clientSpace{
    video(page: $page, orderBy: {field: "video_id", order: DESC}){
      data{
        title,
        author,
        group{
          title
        },
        is_public,
        published_dt,
      }
    } 
  }
}''';

String getGroups = '''
query { 
  clientSpace{
    groups{
      data{
        title,
        group_id,
      }
    }
  }
}''';

String addAlbum = r'''
mutation AddAlbum($title: String!, $author: String!, $group_id: Int!, $files: [Upload!]!) {
  addAlbum(title: $title, author: $author, group_id: $group_id, files: $files,)
}
''';

String addVideo = r'''
mutation AddVideo($title: String!, $author: String!, $group_id: Int!, $url: String!) {
  addVideo(title: $title, author: $author, group_id: $group_id, url: $url,)
}
''';

String getNotifications = r'''
query GetNotifications($page: Int){
  clientSpace {
    notification(page: $page, orderBy: {field: "notification_id", order: DESC}){
      data{
        text,
        is_read,
        notification_id,
        type,
        created_at,
      }
    }
  }
} ''';

String notificateUpdate = r'''
mutation NotificateUpdate($is_read: Int!, $notification_id: ID!) {
  notificateUpdate(is_read: $is_read, notification_id: $notification_id)
}
''';

String getSudscriptionTemplate = '''
query {
  clientSpace {
   subscriptionTemplate{
    data{
      subscription{
        subscription_id,
        need_prolongation,
        start_dt,
        end_dt,
      },
      template_id,
      student,
     	title,
      price,
      description,
      type,
			is_permanent_purchase,
      canBuyNextMonth,
      canProlong,
   	 }
 	 }
  }
}''';

String getStudents = '''
query {
  clientSpace {
    students{
      data{
        student_id,
        first_name,
        middle_name,
        last_name
      }
    }
  }
}''';

String attendance = r'''
mutation Attendance($training_id: Int!, $student_id: Int!, $subscription_id: Int!) {
  attendance(training_id: $training_id, student_id: $student_id, subscription_id: $subscription_id)
} ''';

String getPayments = r'''
query Payments($page: Int){
  clientSpace{
		payments(page: $page){
      data{
        status,
        description
        name
        created_at
        type
        amount
      }
    }
  }
} ''';

String getGroupsAttendance = r'''
query GroupsAttendance($page: Int){
  clientSpace {
  trainings(page: $page) {
    data{
      group{
        title
      }
      area{
        name
      }
      start_dt
      trainingCoach{
        first_name,
        middle_name,
        last_name
      }
      trainingStudent{
        student_id
        presence
        
      }
    }
  }
  }
} ''';

String getIndividualsAttendace = r'''
query IndividualsAttendace($page: Int){
  clientSpace {
    individual(page: $page){
      data{
        status,
        student{
          first_name
          middle_name
          last_name
        }
        presence,
        subscription{
          subscriptionTemplate{
            title
          }
        }
      }
    }
	}
} ''';

String getIndividualFromId = r'''
 query {
  commonSpace TrainingsIndividual($training_id: Int){
    trainingsIndividual(filters: {training_id : $training_id}){
      data{
        start_dt,
        end_dt,
        coach{
          last_name
          first_name,
          middle_name,
        }
      }
    }
  }
} ''';
