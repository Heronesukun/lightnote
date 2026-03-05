import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/account/account_bloc.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'repositories/database_repository.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final databaseRepository = DatabaseRepository();
  await databaseRepository.init();
  
  runApp(LightNoteApp(databaseRepository: databaseRepository));
}

class LightNoteApp extends StatelessWidget {
  final DatabaseRepository databaseRepository;
  
  const LightNoteApp({super.key, required this.databaseRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: databaseRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AccountBloc(databaseRepository)..add(LoadAccounts()),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(databaseRepository)..add(LoadCategories()),
          ),
          BlocProvider(
            create: (context) => TransactionBloc(databaseRepository)..add(LoadTransactions()),
          ),
        ],
        child: MaterialApp(
          title: '轻记',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
