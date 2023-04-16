/// Вход в аккаунт
String logIn = r'''
mutation Login($email: String!, $password: String! ) {
  login(email: $email, password: $password){
    token
    user{
      id
      username
      client_id
    }
  }
}
''';

/// Восстановление пароля
String passRestore = r'''
query PassRestore($email: String!){
  commonSpace {
      passRestore(email: $email)
  }
}
''';

/// Платные группы
String getTrainingsPaid = r'''
query GetTrainingsPaid($from: Date!, $to: Date!){
  commonSpace {
    trainingsPaid(first: 300, filters: {start_dt: {
      from: $from,
      to: $to
    }}){
      data{
        group {
          title,
        }
        start_dt,
        end_dt,
        duration,
        area{
          name
        },
      }
    }
  }
}
''';

/// Бюджетные тренировки
String getTrainingsFree = r'''
query GetTrainingsFree($from: Date!, $to: Date!){
  commonSpace {
    trainingsFree(first: 300, filters: {start_dt: {
      from: $from,
      to: $to
    }}){
      data{
        group {
          title,
        }
        start_dt,
        end_dt,
        duration,
        area{
          name
        },
      }
    }
  }
}
''';

/// Список индивидуальных тренировок и тренеров
String getIndividuals = r'''
query GetIndividuals($from: Date!, $to: Date!){
  commonSpace
  {
    trainingsIndividual(first: 300, filters: {
      start_dt: {
        from: $from,
        to: $to
      }
    }) {
      data{
        attendance{
          student_id
        }
        start_dt,
        end_dt,
        area{
          name
        },
        limit,
        coach{
          first_name,
          middle_name,
          last_name,
          coach_id,
          photo,
          path,
          position,
        }
        training_id,
      }
    }
  }
}
''';
