// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BanksTable extends Banks with TableInfo<$BanksTable, Bank> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BanksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('account_balance'),
  );
  static const VerificationMeta _smsSenderNumberMeta = const VerificationMeta(
    'smsSenderNumber',
  );
  @override
  late final GeneratedColumn<String> smsSenderNumber = GeneratedColumn<String>(
    'sms_sender_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorHex,
    iconName,
    smsSenderNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'banks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bank> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('sms_sender_number')) {
      context.handle(
        _smsSenderNumberMeta,
        smsSenderNumber.isAcceptableOrUnknown(
          data['sms_sender_number']!,
          _smsSenderNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bank map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bank(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      smsSenderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sms_sender_number'],
      ),
    );
  }

  @override
  $BanksTable createAlias(String alias) {
    return $BanksTable(attachedDatabase, alias);
  }
}

class Bank extends DataClass implements Insertable<Bank> {
  final int id;
  final String name;
  final String colorHex;
  final String iconName;
  final String? smsSenderNumber;
  const Bank({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconName,
    this.smsSenderNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['icon_name'] = Variable<String>(iconName);
    if (!nullToAbsent || smsSenderNumber != null) {
      map['sms_sender_number'] = Variable<String>(smsSenderNumber);
    }
    return map;
  }

  BanksCompanion toCompanion(bool nullToAbsent) {
    return BanksCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      iconName: Value(iconName),
      smsSenderNumber: smsSenderNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(smsSenderNumber),
    );
  }

  factory Bank.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bank(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      iconName: serializer.fromJson<String>(json['iconName']),
      smsSenderNumber: serializer.fromJson<String?>(json['smsSenderNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'iconName': serializer.toJson<String>(iconName),
      'smsSenderNumber': serializer.toJson<String?>(smsSenderNumber),
    };
  }

  Bank copyWith({
    int? id,
    String? name,
    String? colorHex,
    String? iconName,
    Value<String?> smsSenderNumber = const Value.absent(),
  }) => Bank(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    iconName: iconName ?? this.iconName,
    smsSenderNumber: smsSenderNumber.present
        ? smsSenderNumber.value
        : this.smsSenderNumber,
  );
  Bank copyWithCompanion(BanksCompanion data) {
    return Bank(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      smsSenderNumber: data.smsSenderNumber.present
          ? data.smsSenderNumber.value
          : this.smsSenderNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bank(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconName: $iconName, ')
          ..write('smsSenderNumber: $smsSenderNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorHex, iconName, smsSenderNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bank &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.iconName == this.iconName &&
          other.smsSenderNumber == this.smsSenderNumber);
}

class BanksCompanion extends UpdateCompanion<Bank> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<String> iconName;
  final Value<String?> smsSenderNumber;
  const BanksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.iconName = const Value.absent(),
    this.smsSenderNumber = const Value.absent(),
  });
  BanksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String colorHex,
    this.iconName = const Value.absent(),
    this.smsSenderNumber = const Value.absent(),
  }) : name = Value(name),
       colorHex = Value(colorHex);
  static Insertable<Bank> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<String>? iconName,
    Expression<String>? smsSenderNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (iconName != null) 'icon_name': iconName,
      if (smsSenderNumber != null) 'sms_sender_number': smsSenderNumber,
    });
  }

  BanksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? colorHex,
    Value<String>? iconName,
    Value<String?>? smsSenderNumber,
  }) {
    return BanksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      smsSenderNumber: smsSenderNumber ?? this.smsSenderNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (smsSenderNumber.present) {
      map['sms_sender_number'] = Variable<String>(smsSenderNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BanksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconName: $iconName, ')
          ..write('smsSenderNumber: $smsSenderNumber')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bankIdMeta = const VerificationMeta('bankId');
  @override
  late final GeneratedColumn<int> bankId = GeneratedColumn<int>(
    'bank_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES banks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountNumberMeta = const VerificationMeta(
    'accountNumber',
  );
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
    'account_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentBalanceRialMeta =
      const VerificationMeta('currentBalanceRial');
  @override
  late final GeneratedColumn<int> currentBalanceRial = GeneratedColumn<int>(
    'current_balance_rial',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _includeInFreeBalanceMeta =
      const VerificationMeta('includeInFreeBalance');
  @override
  late final GeneratedColumn<bool> includeInFreeBalance = GeneratedColumn<bool>(
    'include_in_free_balance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_in_free_balance" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankId,
    title,
    ownerName,
    accountNumber,
    currentBalanceRial,
    includeInFreeBalance,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bank_id')) {
      context.handle(
        _bankIdMeta,
        bankId.isAcceptableOrUnknown(data['bank_id']!, _bankIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bankIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('account_number')) {
      context.handle(
        _accountNumberMeta,
        accountNumber.isAcceptableOrUnknown(
          data['account_number']!,
          _accountNumberMeta,
        ),
      );
    }
    if (data.containsKey('current_balance_rial')) {
      context.handle(
        _currentBalanceRialMeta,
        currentBalanceRial.isAcceptableOrUnknown(
          data['current_balance_rial']!,
          _currentBalanceRialMeta,
        ),
      );
    }
    if (data.containsKey('include_in_free_balance')) {
      context.handle(
        _includeInFreeBalanceMeta,
        includeInFreeBalance.isAcceptableOrUnknown(
          data['include_in_free_balance']!,
          _includeInFreeBalanceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bankId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bank_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      accountNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_number'],
      ),
      currentBalanceRial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_balance_rial'],
      )!,
      includeInFreeBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_in_free_balance'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final int bankId;
  final String title;
  final String? ownerName;
  final String? accountNumber;
  final int currentBalanceRial;
  final bool includeInFreeBalance;
  const Account({
    required this.id,
    required this.bankId,
    required this.title,
    this.ownerName,
    this.accountNumber,
    required this.currentBalanceRial,
    required this.includeInFreeBalance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank_id'] = Variable<int>(bankId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    map['current_balance_rial'] = Variable<int>(currentBalanceRial);
    map['include_in_free_balance'] = Variable<bool>(includeInFreeBalance);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      bankId: Value(bankId),
      title: Value(title),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      currentBalanceRial: Value(currentBalanceRial),
      includeInFreeBalance: Value(includeInFreeBalance),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      bankId: serializer.fromJson<int>(json['bankId']),
      title: serializer.fromJson<String>(json['title']),
      ownerName: serializer.fromJson<String?>(json['ownerName']),
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      currentBalanceRial: serializer.fromJson<int>(json['currentBalanceRial']),
      includeInFreeBalance: serializer.fromJson<bool>(
        json['includeInFreeBalance'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bankId': serializer.toJson<int>(bankId),
      'title': serializer.toJson<String>(title),
      'ownerName': serializer.toJson<String?>(ownerName),
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'currentBalanceRial': serializer.toJson<int>(currentBalanceRial),
      'includeInFreeBalance': serializer.toJson<bool>(includeInFreeBalance),
    };
  }

  Account copyWith({
    int? id,
    int? bankId,
    String? title,
    Value<String?> ownerName = const Value.absent(),
    Value<String?> accountNumber = const Value.absent(),
    int? currentBalanceRial,
    bool? includeInFreeBalance,
  }) => Account(
    id: id ?? this.id,
    bankId: bankId ?? this.bankId,
    title: title ?? this.title,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    accountNumber: accountNumber.present
        ? accountNumber.value
        : this.accountNumber,
    currentBalanceRial: currentBalanceRial ?? this.currentBalanceRial,
    includeInFreeBalance: includeInFreeBalance ?? this.includeInFreeBalance,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      bankId: data.bankId.present ? data.bankId.value : this.bankId,
      title: data.title.present ? data.title.value : this.title,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      currentBalanceRial: data.currentBalanceRial.present
          ? data.currentBalanceRial.value
          : this.currentBalanceRial,
      includeInFreeBalance: data.includeInFreeBalance.present
          ? data.includeInFreeBalance.value
          : this.includeInFreeBalance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('bankId: $bankId, ')
          ..write('title: $title, ')
          ..write('ownerName: $ownerName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('currentBalanceRial: $currentBalanceRial, ')
          ..write('includeInFreeBalance: $includeInFreeBalance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bankId,
    title,
    ownerName,
    accountNumber,
    currentBalanceRial,
    includeInFreeBalance,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.bankId == this.bankId &&
          other.title == this.title &&
          other.ownerName == this.ownerName &&
          other.accountNumber == this.accountNumber &&
          other.currentBalanceRial == this.currentBalanceRial &&
          other.includeInFreeBalance == this.includeInFreeBalance);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<int> bankId;
  final Value<String> title;
  final Value<String?> ownerName;
  final Value<String?> accountNumber;
  final Value<int> currentBalanceRial;
  final Value<bool> includeInFreeBalance;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.bankId = const Value.absent(),
    this.title = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.currentBalanceRial = const Value.absent(),
    this.includeInFreeBalance = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required int bankId,
    required String title,
    this.ownerName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.currentBalanceRial = const Value.absent(),
    this.includeInFreeBalance = const Value.absent(),
  }) : bankId = Value(bankId),
       title = Value(title);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<int>? bankId,
    Expression<String>? title,
    Expression<String>? ownerName,
    Expression<String>? accountNumber,
    Expression<int>? currentBalanceRial,
    Expression<bool>? includeInFreeBalance,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankId != null) 'bank_id': bankId,
      if (title != null) 'title': title,
      if (ownerName != null) 'owner_name': ownerName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (currentBalanceRial != null)
        'current_balance_rial': currentBalanceRial,
      if (includeInFreeBalance != null)
        'include_in_free_balance': includeInFreeBalance,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<int>? bankId,
    Value<String>? title,
    Value<String?>? ownerName,
    Value<String?>? accountNumber,
    Value<int>? currentBalanceRial,
    Value<bool>? includeInFreeBalance,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      bankId: bankId ?? this.bankId,
      title: title ?? this.title,
      ownerName: ownerName ?? this.ownerName,
      accountNumber: accountNumber ?? this.accountNumber,
      currentBalanceRial: currentBalanceRial ?? this.currentBalanceRial,
      includeInFreeBalance: includeInFreeBalance ?? this.includeInFreeBalance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bankId.present) {
      map['bank_id'] = Variable<int>(bankId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (currentBalanceRial.present) {
      map['current_balance_rial'] = Variable<int>(currentBalanceRial.value);
    }
    if (includeInFreeBalance.present) {
      map['include_in_free_balance'] = Variable<bool>(
        includeInFreeBalance.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('bankId: $bankId, ')
          ..write('title: $title, ')
          ..write('ownerName: $ownerName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('currentBalanceRial: $currentBalanceRial, ')
          ..write('includeInFreeBalance: $includeInFreeBalance')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    iconCode,
    colorHex,
    type,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String title;
  final int iconCode;
  final String colorHex;
  final String type;
  final bool isDefault;
  const Category({
    required this.id,
    required this.title,
    required this.iconCode,
    required this.colorHex,
    required this.type,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['icon_code'] = Variable<int>(iconCode);
    map['color_hex'] = Variable<String>(colorHex);
    map['type'] = Variable<String>(type);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      title: Value(title),
      iconCode: Value(iconCode),
      colorHex: Value(colorHex),
      type: Value(type),
      isDefault: Value(isDefault),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      type: serializer.fromJson<String>(json['type']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'iconCode': serializer.toJson<int>(iconCode),
      'colorHex': serializer.toJson<String>(colorHex),
      'type': serializer.toJson<String>(type),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  Category copyWith({
    int? id,
    String? title,
    int? iconCode,
    String? colorHex,
    String? type,
    bool? isDefault,
  }) => Category(
    id: id ?? this.id,
    title: title ?? this.title,
    iconCode: iconCode ?? this.iconCode,
    colorHex: colorHex ?? this.colorHex,
    type: type ?? this.type,
    isDefault: isDefault ?? this.isDefault,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      type: data.type.present ? data.type.value : this.type,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorHex: $colorHex, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, iconCode, colorHex, type, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.title == this.title &&
          other.iconCode == this.iconCode &&
          other.colorHex == this.colorHex &&
          other.type == this.type &&
          other.isDefault == this.isDefault);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> iconCode;
  final Value<String> colorHex;
  final Value<String> type;
  final Value<bool> isDefault;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.type = const Value.absent(),
    this.isDefault = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int iconCode,
    required String colorHex,
    required String type,
    this.isDefault = const Value.absent(),
  }) : title = Value(title),
       iconCode = Value(iconCode),
       colorHex = Value(colorHex),
       type = Value(type);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? iconCode,
    Expression<String>? colorHex,
    Expression<String>? type,
    Expression<bool>? isDefault,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorHex != null) 'color_hex': colorHex,
      if (type != null) 'type': type,
      if (isDefault != null) 'is_default': isDefault,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? iconCode,
    Value<String>? colorHex,
    Value<String>? type,
    Value<bool>? isDefault,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCode: iconCode ?? this.iconCode,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorHex: $colorHex, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }
}

class $PlannedPaymentsTable extends PlannedPayments
    with TableInfo<$PlannedPaymentsTable, PlannedPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountRialMeta = const VerificationMeta(
    'amountRial',
  );
  @override
  late final GeneratedColumn<int> amountRial = GeneratedColumn<int>(
    'amount_rial',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    categoryId,
    title,
    amountRial,
    dueDate,
    status,
    isRecurring,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_rial')) {
      context.handle(
        _amountRialMeta,
        amountRial.isAcceptableOrUnknown(data['amount_rial']!, _amountRialMeta),
      );
    } else if (isInserting) {
      context.missing(_amountRialMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amountRial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_rial'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
    );
  }

  @override
  $PlannedPaymentsTable createAlias(String alias) {
    return $PlannedPaymentsTable(attachedDatabase, alias);
  }
}

class PlannedPayment extends DataClass implements Insertable<PlannedPayment> {
  final int id;
  final int accountId;
  final int? categoryId;
  final String title;
  final int amountRial;
  final DateTime dueDate;
  final String status;
  final bool isRecurring;
  const PlannedPayment({
    required this.id,
    required this.accountId,
    this.categoryId,
    required this.title,
    required this.amountRial,
    required this.dueDate,
    required this.status,
    required this.isRecurring,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['title'] = Variable<String>(title);
    map['amount_rial'] = Variable<int>(amountRial);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['status'] = Variable<String>(status);
    map['is_recurring'] = Variable<bool>(isRecurring);
    return map;
  }

  PlannedPaymentsCompanion toCompanion(bool nullToAbsent) {
    return PlannedPaymentsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      title: Value(title),
      amountRial: Value(amountRial),
      dueDate: Value(dueDate),
      status: Value(status),
      isRecurring: Value(isRecurring),
    );
  }

  factory PlannedPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedPayment(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      title: serializer.fromJson<String>(json['title']),
      amountRial: serializer.fromJson<int>(json['amountRial']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'title': serializer.toJson<String>(title),
      'amountRial': serializer.toJson<int>(amountRial),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'status': serializer.toJson<String>(status),
      'isRecurring': serializer.toJson<bool>(isRecurring),
    };
  }

  PlannedPayment copyWith({
    int? id,
    int? accountId,
    Value<int?> categoryId = const Value.absent(),
    String? title,
    int? amountRial,
    DateTime? dueDate,
    String? status,
    bool? isRecurring,
  }) => PlannedPayment(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    title: title ?? this.title,
    amountRial: amountRial ?? this.amountRial,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    isRecurring: isRecurring ?? this.isRecurring,
  );
  PlannedPayment copyWithCompanion(PlannedPaymentsCompanion data) {
    return PlannedPayment(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      title: data.title.present ? data.title.value : this.title,
      amountRial: data.amountRial.present
          ? data.amountRial.value
          : this.amountRial,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedPayment(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('amountRial: $amountRial, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('isRecurring: $isRecurring')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    categoryId,
    title,
    amountRial,
    dueDate,
    status,
    isRecurring,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedPayment &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.amountRial == this.amountRial &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.isRecurring == this.isRecurring);
}

class PlannedPaymentsCompanion extends UpdateCompanion<PlannedPayment> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int?> categoryId;
  final Value<String> title;
  final Value<int> amountRial;
  final Value<DateTime> dueDate;
  final Value<String> status;
  final Value<bool> isRecurring;
  const PlannedPaymentsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.amountRial = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.isRecurring = const Value.absent(),
  });
  PlannedPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    this.categoryId = const Value.absent(),
    required String title,
    required int amountRial,
    required DateTime dueDate,
    this.status = const Value.absent(),
    this.isRecurring = const Value.absent(),
  }) : accountId = Value(accountId),
       title = Value(title),
       amountRial = Value(amountRial),
       dueDate = Value(dueDate);
  static Insertable<PlannedPayment> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? categoryId,
    Expression<String>? title,
    Expression<int>? amountRial,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<bool>? isRecurring,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (amountRial != null) 'amount_rial': amountRial,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (isRecurring != null) 'is_recurring': isRecurring,
    });
  }

  PlannedPaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<int?>? categoryId,
    Value<String>? title,
    Value<int>? amountRial,
    Value<DateTime>? dueDate,
    Value<String>? status,
    Value<bool>? isRecurring,
  }) {
    return PlannedPaymentsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      amountRial: amountRial ?? this.amountRial,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amountRial.present) {
      map['amount_rial'] = Variable<int>(amountRial.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('amountRial: $amountRial, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('isRecurring: $isRecurring')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _amountRialMeta = const VerificationMeta(
    'amountRial',
  );
  @override
  late final GeneratedColumn<int> amountRial = GeneratedColumn<int>(
    'amount_rial',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawSmsTextMeta = const VerificationMeta(
    'rawSmsText',
  );
  @override
  late final GeneratedColumn<String> rawSmsText = GeneratedColumn<String>(
    'raw_sms_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCategorizedMeta = const VerificationMeta(
    'isCategorized',
  );
  @override
  late final GeneratedColumn<bool> isCategorized = GeneratedColumn<bool>(
    'is_categorized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_categorized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    categoryId,
    amountRial,
    type,
    occurredAt,
    rawSmsText,
    isCategorized,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('amount_rial')) {
      context.handle(
        _amountRialMeta,
        amountRial.isAcceptableOrUnknown(data['amount_rial']!, _amountRialMeta),
      );
    } else if (isInserting) {
      context.missing(_amountRialMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('raw_sms_text')) {
      context.handle(
        _rawSmsTextMeta,
        rawSmsText.isAcceptableOrUnknown(
          data['raw_sms_text']!,
          _rawSmsTextMeta,
        ),
      );
    }
    if (data.containsKey('is_categorized')) {
      context.handle(
        _isCategorizedMeta,
        isCategorized.isAcceptableOrUnknown(
          data['is_categorized']!,
          _isCategorizedMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      amountRial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_rial'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      rawSmsText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_sms_text'],
      ),
      isCategorized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_categorized'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int accountId;
  final int? categoryId;
  final int amountRial;
  final String type;
  final DateTime occurredAt;
  final String? rawSmsText;
  final bool isCategorized;
  final String? description;
  const Transaction({
    required this.id,
    required this.accountId,
    this.categoryId,
    required this.amountRial,
    required this.type,
    required this.occurredAt,
    this.rawSmsText,
    required this.isCategorized,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['amount_rial'] = Variable<int>(amountRial);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || rawSmsText != null) {
      map['raw_sms_text'] = Variable<String>(rawSmsText);
    }
    map['is_categorized'] = Variable<bool>(isCategorized);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amountRial: Value(amountRial),
      type: Value(type),
      occurredAt: Value(occurredAt),
      rawSmsText: rawSmsText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSmsText),
      isCategorized: Value(isCategorized),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      amountRial: serializer.fromJson<int>(json['amountRial']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      rawSmsText: serializer.fromJson<String?>(json['rawSmsText']),
      isCategorized: serializer.fromJson<bool>(json['isCategorized']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'amountRial': serializer.toJson<int>(amountRial),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'rawSmsText': serializer.toJson<String?>(rawSmsText),
      'isCategorized': serializer.toJson<bool>(isCategorized),
      'description': serializer.toJson<String?>(description),
    };
  }

  Transaction copyWith({
    int? id,
    int? accountId,
    Value<int?> categoryId = const Value.absent(),
    int? amountRial,
    String? type,
    DateTime? occurredAt,
    Value<String?> rawSmsText = const Value.absent(),
    bool? isCategorized,
    Value<String?> description = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    amountRial: amountRial ?? this.amountRial,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    rawSmsText: rawSmsText.present ? rawSmsText.value : this.rawSmsText,
    isCategorized: isCategorized ?? this.isCategorized,
    description: description.present ? description.value : this.description,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountRial: data.amountRial.present
          ? data.amountRial.value
          : this.amountRial,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      rawSmsText: data.rawSmsText.present
          ? data.rawSmsText.value
          : this.rawSmsText,
      isCategorized: data.isCategorized.present
          ? data.isCategorized.value
          : this.isCategorized,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountRial: $amountRial, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rawSmsText: $rawSmsText, ')
          ..write('isCategorized: $isCategorized, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    categoryId,
    amountRial,
    type,
    occurredAt,
    rawSmsText,
    isCategorized,
    description,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.amountRial == this.amountRial &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.rawSmsText == this.rawSmsText &&
          other.isCategorized == this.isCategorized &&
          other.description == this.description);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int?> categoryId;
  final Value<int> amountRial;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String?> rawSmsText;
  final Value<bool> isCategorized;
  final Value<String?> description;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountRial = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rawSmsText = const Value.absent(),
    this.isCategorized = const Value.absent(),
    this.description = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    this.categoryId = const Value.absent(),
    required int amountRial,
    required String type,
    required DateTime occurredAt,
    this.rawSmsText = const Value.absent(),
    this.isCategorized = const Value.absent(),
    this.description = const Value.absent(),
  }) : accountId = Value(accountId),
       amountRial = Value(amountRial),
       type = Value(type),
       occurredAt = Value(occurredAt);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? categoryId,
    Expression<int>? amountRial,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? rawSmsText,
    Expression<bool>? isCategorized,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (amountRial != null) 'amount_rial': amountRial,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rawSmsText != null) 'raw_sms_text': rawSmsText,
      if (isCategorized != null) 'is_categorized': isCategorized,
      if (description != null) 'description': description,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<int?>? categoryId,
    Value<int>? amountRial,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String?>? rawSmsText,
    Value<bool>? isCategorized,
    Value<String?>? description,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amountRial: amountRial ?? this.amountRial,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      rawSmsText: rawSmsText ?? this.rawSmsText,
      isCategorized: isCategorized ?? this.isCategorized,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amountRial.present) {
      map['amount_rial'] = Variable<int>(amountRial.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rawSmsText.present) {
      map['raw_sms_text'] = Variable<String>(rawSmsText.value);
    }
    if (isCategorized.present) {
      map['is_categorized'] = Variable<bool>(isCategorized.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountRial: $amountRial, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rawSmsText: $rawSmsText, ')
          ..write('isCategorized: $isCategorized, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $SalaryPeriodsTable extends SalaryPeriods
    with TableInfo<$SalaryPeriodsTable, SalaryPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalaryPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startDayOfMonthMeta = const VerificationMeta(
    'startDayOfMonth',
  );
  @override
  late final GeneratedColumn<int> startDayOfMonth = GeneratedColumn<int>(
    'start_day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, startDayOfMonth, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'salary_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalaryPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_day_of_month')) {
      context.handle(
        _startDayOfMonthMeta,
        startDayOfMonth.isAcceptableOrUnknown(
          data['start_day_of_month']!,
          _startDayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalaryPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalaryPeriod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startDayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_day_of_month'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $SalaryPeriodsTable createAlias(String alias) {
    return $SalaryPeriodsTable(attachedDatabase, alias);
  }
}

class SalaryPeriod extends DataClass implements Insertable<SalaryPeriod> {
  final int id;
  final int startDayOfMonth;
  final bool isActive;
  const SalaryPeriod({
    required this.id,
    required this.startDayOfMonth,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_day_of_month'] = Variable<int>(startDayOfMonth);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  SalaryPeriodsCompanion toCompanion(bool nullToAbsent) {
    return SalaryPeriodsCompanion(
      id: Value(id),
      startDayOfMonth: Value(startDayOfMonth),
      isActive: Value(isActive),
    );
  }

  factory SalaryPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalaryPeriod(
      id: serializer.fromJson<int>(json['id']),
      startDayOfMonth: serializer.fromJson<int>(json['startDayOfMonth']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startDayOfMonth': serializer.toJson<int>(startDayOfMonth),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  SalaryPeriod copyWith({int? id, int? startDayOfMonth, bool? isActive}) =>
      SalaryPeriod(
        id: id ?? this.id,
        startDayOfMonth: startDayOfMonth ?? this.startDayOfMonth,
        isActive: isActive ?? this.isActive,
      );
  SalaryPeriod copyWithCompanion(SalaryPeriodsCompanion data) {
    return SalaryPeriod(
      id: data.id.present ? data.id.value : this.id,
      startDayOfMonth: data.startDayOfMonth.present
          ? data.startDayOfMonth.value
          : this.startDayOfMonth,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalaryPeriod(')
          ..write('id: $id, ')
          ..write('startDayOfMonth: $startDayOfMonth, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startDayOfMonth, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalaryPeriod &&
          other.id == this.id &&
          other.startDayOfMonth == this.startDayOfMonth &&
          other.isActive == this.isActive);
}

class SalaryPeriodsCompanion extends UpdateCompanion<SalaryPeriod> {
  final Value<int> id;
  final Value<int> startDayOfMonth;
  final Value<bool> isActive;
  const SalaryPeriodsCompanion({
    this.id = const Value.absent(),
    this.startDayOfMonth = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  SalaryPeriodsCompanion.insert({
    this.id = const Value.absent(),
    this.startDayOfMonth = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  static Insertable<SalaryPeriod> custom({
    Expression<int>? id,
    Expression<int>? startDayOfMonth,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDayOfMonth != null) 'start_day_of_month': startDayOfMonth,
      if (isActive != null) 'is_active': isActive,
    });
  }

  SalaryPeriodsCompanion copyWith({
    Value<int>? id,
    Value<int>? startDayOfMonth,
    Value<bool>? isActive,
  }) {
    return SalaryPeriodsCompanion(
      id: id ?? this.id,
      startDayOfMonth: startDayOfMonth ?? this.startDayOfMonth,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startDayOfMonth.present) {
      map['start_day_of_month'] = Variable<int>(startDayOfMonth.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalaryPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('startDayOfMonth: $startDayOfMonth, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $SmsTemplatesTable extends SmsTemplates
    with TableInfo<$SmsTemplatesTable, SmsTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bankIdMeta = const VerificationMeta('bankId');
  @override
  late final GeneratedColumn<int> bankId = GeneratedColumn<int>(
    'bank_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES banks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _patternNameMeta = const VerificationMeta(
    'patternName',
  );
  @override
  late final GeneratedColumn<String> patternName = GeneratedColumn<String>(
    'pattern_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regexMeta = const VerificationMeta('regex');
  @override
  late final GeneratedColumn<String> regex = GeneratedColumn<String>(
    'regex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountGroupIndexMeta = const VerificationMeta(
    'amountGroupIndex',
  );
  @override
  late final GeneratedColumn<int> amountGroupIndex = GeneratedColumn<int>(
    'amount_group_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _balanceGroupIndexMeta = const VerificationMeta(
    'balanceGroupIndex',
  );
  @override
  late final GeneratedColumn<int> balanceGroupIndex = GeneratedColumn<int>(
    'balance_group_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _withdrawKeywordMeta = const VerificationMeta(
    'withdrawKeyword',
  );
  @override
  late final GeneratedColumn<String> withdrawKeyword = GeneratedColumn<String>(
    'withdraw_keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('برداشت'),
  );
  static const VerificationMeta _depositKeywordMeta = const VerificationMeta(
    'depositKeyword',
  );
  @override
  late final GeneratedColumn<String> depositKeyword = GeneratedColumn<String>(
    'deposit_keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('واریز'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankId,
    patternName,
    regex,
    amountGroupIndex,
    balanceGroupIndex,
    withdrawKeyword,
    depositKeyword,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmsTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bank_id')) {
      context.handle(
        _bankIdMeta,
        bankId.isAcceptableOrUnknown(data['bank_id']!, _bankIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bankIdMeta);
    }
    if (data.containsKey('pattern_name')) {
      context.handle(
        _patternNameMeta,
        patternName.isAcceptableOrUnknown(
          data['pattern_name']!,
          _patternNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patternNameMeta);
    }
    if (data.containsKey('regex')) {
      context.handle(
        _regexMeta,
        regex.isAcceptableOrUnknown(data['regex']!, _regexMeta),
      );
    } else if (isInserting) {
      context.missing(_regexMeta);
    }
    if (data.containsKey('amount_group_index')) {
      context.handle(
        _amountGroupIndexMeta,
        amountGroupIndex.isAcceptableOrUnknown(
          data['amount_group_index']!,
          _amountGroupIndexMeta,
        ),
      );
    }
    if (data.containsKey('balance_group_index')) {
      context.handle(
        _balanceGroupIndexMeta,
        balanceGroupIndex.isAcceptableOrUnknown(
          data['balance_group_index']!,
          _balanceGroupIndexMeta,
        ),
      );
    }
    if (data.containsKey('withdraw_keyword')) {
      context.handle(
        _withdrawKeywordMeta,
        withdrawKeyword.isAcceptableOrUnknown(
          data['withdraw_keyword']!,
          _withdrawKeywordMeta,
        ),
      );
    }
    if (data.containsKey('deposit_keyword')) {
      context.handle(
        _depositKeywordMeta,
        depositKeyword.isAcceptableOrUnknown(
          data['deposit_keyword']!,
          _depositKeywordMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmsTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmsTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bankId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bank_id'],
      )!,
      patternName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern_name'],
      )!,
      regex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regex'],
      )!,
      amountGroupIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_group_index'],
      )!,
      balanceGroupIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_group_index'],
      ),
      withdrawKeyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}withdraw_keyword'],
      )!,
      depositKeyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deposit_keyword'],
      )!,
    );
  }

  @override
  $SmsTemplatesTable createAlias(String alias) {
    return $SmsTemplatesTable(attachedDatabase, alias);
  }
}

class SmsTemplate extends DataClass implements Insertable<SmsTemplate> {
  final int id;
  final int bankId;
  final String patternName;
  final String regex;
  final int amountGroupIndex;
  final int? balanceGroupIndex;
  final String withdrawKeyword;
  final String depositKeyword;
  const SmsTemplate({
    required this.id,
    required this.bankId,
    required this.patternName,
    required this.regex,
    required this.amountGroupIndex,
    this.balanceGroupIndex,
    required this.withdrawKeyword,
    required this.depositKeyword,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank_id'] = Variable<int>(bankId);
    map['pattern_name'] = Variable<String>(patternName);
    map['regex'] = Variable<String>(regex);
    map['amount_group_index'] = Variable<int>(amountGroupIndex);
    if (!nullToAbsent || balanceGroupIndex != null) {
      map['balance_group_index'] = Variable<int>(balanceGroupIndex);
    }
    map['withdraw_keyword'] = Variable<String>(withdrawKeyword);
    map['deposit_keyword'] = Variable<String>(depositKeyword);
    return map;
  }

  SmsTemplatesCompanion toCompanion(bool nullToAbsent) {
    return SmsTemplatesCompanion(
      id: Value(id),
      bankId: Value(bankId),
      patternName: Value(patternName),
      regex: Value(regex),
      amountGroupIndex: Value(amountGroupIndex),
      balanceGroupIndex: balanceGroupIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceGroupIndex),
      withdrawKeyword: Value(withdrawKeyword),
      depositKeyword: Value(depositKeyword),
    );
  }

  factory SmsTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmsTemplate(
      id: serializer.fromJson<int>(json['id']),
      bankId: serializer.fromJson<int>(json['bankId']),
      patternName: serializer.fromJson<String>(json['patternName']),
      regex: serializer.fromJson<String>(json['regex']),
      amountGroupIndex: serializer.fromJson<int>(json['amountGroupIndex']),
      balanceGroupIndex: serializer.fromJson<int?>(json['balanceGroupIndex']),
      withdrawKeyword: serializer.fromJson<String>(json['withdrawKeyword']),
      depositKeyword: serializer.fromJson<String>(json['depositKeyword']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bankId': serializer.toJson<int>(bankId),
      'patternName': serializer.toJson<String>(patternName),
      'regex': serializer.toJson<String>(regex),
      'amountGroupIndex': serializer.toJson<int>(amountGroupIndex),
      'balanceGroupIndex': serializer.toJson<int?>(balanceGroupIndex),
      'withdrawKeyword': serializer.toJson<String>(withdrawKeyword),
      'depositKeyword': serializer.toJson<String>(depositKeyword),
    };
  }

  SmsTemplate copyWith({
    int? id,
    int? bankId,
    String? patternName,
    String? regex,
    int? amountGroupIndex,
    Value<int?> balanceGroupIndex = const Value.absent(),
    String? withdrawKeyword,
    String? depositKeyword,
  }) => SmsTemplate(
    id: id ?? this.id,
    bankId: bankId ?? this.bankId,
    patternName: patternName ?? this.patternName,
    regex: regex ?? this.regex,
    amountGroupIndex: amountGroupIndex ?? this.amountGroupIndex,
    balanceGroupIndex: balanceGroupIndex.present
        ? balanceGroupIndex.value
        : this.balanceGroupIndex,
    withdrawKeyword: withdrawKeyword ?? this.withdrawKeyword,
    depositKeyword: depositKeyword ?? this.depositKeyword,
  );
  SmsTemplate copyWithCompanion(SmsTemplatesCompanion data) {
    return SmsTemplate(
      id: data.id.present ? data.id.value : this.id,
      bankId: data.bankId.present ? data.bankId.value : this.bankId,
      patternName: data.patternName.present
          ? data.patternName.value
          : this.patternName,
      regex: data.regex.present ? data.regex.value : this.regex,
      amountGroupIndex: data.amountGroupIndex.present
          ? data.amountGroupIndex.value
          : this.amountGroupIndex,
      balanceGroupIndex: data.balanceGroupIndex.present
          ? data.balanceGroupIndex.value
          : this.balanceGroupIndex,
      withdrawKeyword: data.withdrawKeyword.present
          ? data.withdrawKeyword.value
          : this.withdrawKeyword,
      depositKeyword: data.depositKeyword.present
          ? data.depositKeyword.value
          : this.depositKeyword,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsTemplate(')
          ..write('id: $id, ')
          ..write('bankId: $bankId, ')
          ..write('patternName: $patternName, ')
          ..write('regex: $regex, ')
          ..write('amountGroupIndex: $amountGroupIndex, ')
          ..write('balanceGroupIndex: $balanceGroupIndex, ')
          ..write('withdrawKeyword: $withdrawKeyword, ')
          ..write('depositKeyword: $depositKeyword')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bankId,
    patternName,
    regex,
    amountGroupIndex,
    balanceGroupIndex,
    withdrawKeyword,
    depositKeyword,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsTemplate &&
          other.id == this.id &&
          other.bankId == this.bankId &&
          other.patternName == this.patternName &&
          other.regex == this.regex &&
          other.amountGroupIndex == this.amountGroupIndex &&
          other.balanceGroupIndex == this.balanceGroupIndex &&
          other.withdrawKeyword == this.withdrawKeyword &&
          other.depositKeyword == this.depositKeyword);
}

class SmsTemplatesCompanion extends UpdateCompanion<SmsTemplate> {
  final Value<int> id;
  final Value<int> bankId;
  final Value<String> patternName;
  final Value<String> regex;
  final Value<int> amountGroupIndex;
  final Value<int?> balanceGroupIndex;
  final Value<String> withdrawKeyword;
  final Value<String> depositKeyword;
  const SmsTemplatesCompanion({
    this.id = const Value.absent(),
    this.bankId = const Value.absent(),
    this.patternName = const Value.absent(),
    this.regex = const Value.absent(),
    this.amountGroupIndex = const Value.absent(),
    this.balanceGroupIndex = const Value.absent(),
    this.withdrawKeyword = const Value.absent(),
    this.depositKeyword = const Value.absent(),
  });
  SmsTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required int bankId,
    required String patternName,
    required String regex,
    this.amountGroupIndex = const Value.absent(),
    this.balanceGroupIndex = const Value.absent(),
    this.withdrawKeyword = const Value.absent(),
    this.depositKeyword = const Value.absent(),
  }) : bankId = Value(bankId),
       patternName = Value(patternName),
       regex = Value(regex);
  static Insertable<SmsTemplate> custom({
    Expression<int>? id,
    Expression<int>? bankId,
    Expression<String>? patternName,
    Expression<String>? regex,
    Expression<int>? amountGroupIndex,
    Expression<int>? balanceGroupIndex,
    Expression<String>? withdrawKeyword,
    Expression<String>? depositKeyword,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankId != null) 'bank_id': bankId,
      if (patternName != null) 'pattern_name': patternName,
      if (regex != null) 'regex': regex,
      if (amountGroupIndex != null) 'amount_group_index': amountGroupIndex,
      if (balanceGroupIndex != null) 'balance_group_index': balanceGroupIndex,
      if (withdrawKeyword != null) 'withdraw_keyword': withdrawKeyword,
      if (depositKeyword != null) 'deposit_keyword': depositKeyword,
    });
  }

  SmsTemplatesCompanion copyWith({
    Value<int>? id,
    Value<int>? bankId,
    Value<String>? patternName,
    Value<String>? regex,
    Value<int>? amountGroupIndex,
    Value<int?>? balanceGroupIndex,
    Value<String>? withdrawKeyword,
    Value<String>? depositKeyword,
  }) {
    return SmsTemplatesCompanion(
      id: id ?? this.id,
      bankId: bankId ?? this.bankId,
      patternName: patternName ?? this.patternName,
      regex: regex ?? this.regex,
      amountGroupIndex: amountGroupIndex ?? this.amountGroupIndex,
      balanceGroupIndex: balanceGroupIndex ?? this.balanceGroupIndex,
      withdrawKeyword: withdrawKeyword ?? this.withdrawKeyword,
      depositKeyword: depositKeyword ?? this.depositKeyword,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bankId.present) {
      map['bank_id'] = Variable<int>(bankId.value);
    }
    if (patternName.present) {
      map['pattern_name'] = Variable<String>(patternName.value);
    }
    if (regex.present) {
      map['regex'] = Variable<String>(regex.value);
    }
    if (amountGroupIndex.present) {
      map['amount_group_index'] = Variable<int>(amountGroupIndex.value);
    }
    if (balanceGroupIndex.present) {
      map['balance_group_index'] = Variable<int>(balanceGroupIndex.value);
    }
    if (withdrawKeyword.present) {
      map['withdraw_keyword'] = Variable<String>(withdrawKeyword.value);
    }
    if (depositKeyword.present) {
      map['deposit_keyword'] = Variable<String>(depositKeyword.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('bankId: $bankId, ')
          ..write('patternName: $patternName, ')
          ..write('regex: $regex, ')
          ..write('amountGroupIndex: $amountGroupIndex, ')
          ..write('balanceGroupIndex: $balanceGroupIndex, ')
          ..write('withdrawKeyword: $withdrawKeyword, ')
          ..write('depositKeyword: $depositKeyword')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BanksTable banks = $BanksTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $PlannedPaymentsTable plannedPayments = $PlannedPaymentsTable(
    this,
  );
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $SalaryPeriodsTable salaryPeriods = $SalaryPeriodsTable(this);
  late final $SmsTemplatesTable smsTemplates = $SmsTemplatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    banks,
    accounts,
    categories,
    plannedPayments,
    transactions,
    salaryPeriods,
    smsTemplates,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'banks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('accounts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('planned_payments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('planned_payments', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'banks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sms_templates', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BanksTableCreateCompanionBuilder = BanksCompanion Function({
  Value<int> id,
  required String name,
  required String colorHex,
  Value<String> iconName,
  Value<String?> smsSenderNumber,
});
typedef $$BanksTableUpdateCompanionBuilder = BanksCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> colorHex,
  Value<String> iconName,
  Value<String?> smsSenderNumber,
});

final class $$BanksTableReferences
    extends BaseReferences<_$AppDatabase, $BanksTable, Bank> {
  $$BanksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountsTable, List<Account>> _accountsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.accounts,
    aliasName: 'banks__id__accounts__bank_id',
  );

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.bankId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SmsTemplatesTable, List<SmsTemplate>>
  _smsTemplatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.smsTemplates,
    aliasName: 'banks__id__sms_templates__bank_id',
  );

  $$SmsTemplatesTableProcessedTableManager get smsTemplatesRefs {
    final manager = $$SmsTemplatesTableTableManager(
      $_db,
      $_db.smsTemplates,
    ).filter((f) => f.bankId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_smsTemplatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BanksTableFilterComposer extends Composer<_$AppDatabase, $BanksTable> {
  $$BanksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smsSenderNumber => $composableBuilder(
    column: $table.smsSenderNumber,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> accountsRefs(
    Expression<bool> Function($$AccountsTableFilterComposer f) f,
  ) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.bankId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> smsTemplatesRefs(
    Expression<bool> Function($$SmsTemplatesTableFilterComposer f) f,
  ) {
    final $$SmsTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.smsTemplates,
      getReferencedColumn: (t) => t.bankId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SmsTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.smsTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BanksTableOrderingComposer
    extends Composer<_$AppDatabase, $BanksTable> {
  $$BanksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smsSenderNumber => $composableBuilder(
    column: $table.smsSenderNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BanksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BanksTable> {
  $$BanksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get smsSenderNumber => $composableBuilder(
    column: $table.smsSenderNumber,
    builder: (column) => column,
  );

  Expression<T> accountsRefs<T extends Object>(
    Expression<T> Function($$AccountsTableAnnotationComposer a) f,
  ) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.bankId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> smsTemplatesRefs<T extends Object>(
    Expression<T> Function($$SmsTemplatesTableAnnotationComposer a) f,
  ) {
    final $$SmsTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.smsTemplates,
      getReferencedColumn: (t) => t.bankId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SmsTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.smsTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BanksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BanksTable,
          Bank,
          $$BanksTableFilterComposer,
          $$BanksTableOrderingComposer,
          $$BanksTableAnnotationComposer,
          $$BanksTableCreateCompanionBuilder,
          $$BanksTableUpdateCompanionBuilder,
          (Bank, $$BanksTableReferences),
          Bank,
          PrefetchHooks Function({bool accountsRefs, bool smsTemplatesRefs})
        > {
  $$BanksTableTableManager(_$AppDatabase db, $BanksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BanksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BanksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BanksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String?> smsSenderNumber = const Value.absent(),
              }) => BanksCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                iconName: iconName,
                smsSenderNumber: smsSenderNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String colorHex,
                Value<String> iconName = const Value.absent(),
                Value<String?> smsSenderNumber = const Value.absent(),
              }) => BanksCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                iconName: iconName,
                smsSenderNumber: smsSenderNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BanksTable, Bank>(table),
                  $$BanksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({accountsRefs = false, smsTemplatesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (accountsRefs) db.accounts,
                    if (smsTemplatesRefs) db.smsTemplates,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (accountsRefs)
                        await $_getPrefetchedData<Bank, $BanksTable, Account>(
                          currentTable: table,
                          referencedTable: $$BanksTableReferences
                              ._accountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BanksTableReferences(
                                db,
                                table,
                                p0,
                              ).accountsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bankId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (smsTemplatesRefs)
                        await $_getPrefetchedData<
                          Bank,
                          $BanksTable,
                          SmsTemplate
                        >(
                          currentTable: table,
                          referencedTable: $$BanksTableReferences
                              ._smsTemplatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BanksTableReferences(
                                db,
                                table,
                                p0,
                              ).smsTemplatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bankId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BanksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BanksTable,
      Bank,
      $$BanksTableFilterComposer,
      $$BanksTableOrderingComposer,
      $$BanksTableAnnotationComposer,
      $$BanksTableCreateCompanionBuilder,
      $$BanksTableUpdateCompanionBuilder,
      (Bank, $$BanksTableReferences),
      Bank,
      PrefetchHooks Function({bool accountsRefs, bool smsTemplatesRefs})
    >;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required int bankId,
  required String title,
  Value<String?> ownerName,
  Value<String?> accountNumber,
  Value<int> currentBalanceRial,
  Value<bool> includeInFreeBalance,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<int> bankId,
  Value<String> title,
  Value<String?> ownerName,
  Value<String?> accountNumber,
  Value<int> currentBalanceRial,
  Value<bool> includeInFreeBalance,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BanksTable _bankIdTable(_$AppDatabase db) =>
      db.banks.createAlias('accounts__bank_id__banks__id');

  $$BanksTableProcessedTableManager get bankId {
    final $_column = $_itemColumn<int>('bank_id')!;

    final manager = $$BanksTableTableManager(
      $_db,
      $_db.banks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bankIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlannedPaymentsTable, List<PlannedPayment>>
  _plannedPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.plannedPayments,
    aliasName: 'accounts__id__planned_payments__account_id',
  );

  $$PlannedPaymentsTableProcessedTableManager get plannedPaymentsRefs {
    final manager = $$PlannedPaymentsTableTableManager(
      $_db,
      $_db.plannedPayments,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plannedPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'accounts__id__transactions__account_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentBalanceRial => $composableBuilder(
    column: $table.currentBalanceRial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeInFreeBalance => $composableBuilder(
    column: $table.includeInFreeBalance,
    builder: (column) => ColumnFilters(column),
  );

  $$BanksTableFilterComposer get bankId {
    final $$BanksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bankId,
      referencedTable: $db.banks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BanksTableFilterComposer(
            $db: $db,
            $table: $db.banks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> plannedPaymentsRefs(
    Expression<bool> Function($$PlannedPaymentsTableFilterComposer f) f,
  ) {
    final $$PlannedPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plannedPayments,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.plannedPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentBalanceRial => $composableBuilder(
    column: $table.currentBalanceRial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeInFreeBalance => $composableBuilder(
    column: $table.includeInFreeBalance,
    builder: (column) => ColumnOrderings(column),
  );

  $$BanksTableOrderingComposer get bankId {
    final $$BanksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bankId,
      referencedTable: $db.banks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BanksTableOrderingComposer(
            $db: $db,
            $table: $db.banks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentBalanceRial => $composableBuilder(
    column: $table.currentBalanceRial,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeInFreeBalance => $composableBuilder(
    column: $table.includeInFreeBalance,
    builder: (column) => column,
  );

  $$BanksTableAnnotationComposer get bankId {
    final $$BanksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bankId,
      referencedTable: $db.banks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BanksTableAnnotationComposer(
            $db: $db,
            $table: $db.banks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> plannedPaymentsRefs<T extends Object>(
    Expression<T> Function($$PlannedPaymentsTableAnnotationComposer a) f,
  ) {
    final $$PlannedPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plannedPayments,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.plannedPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({
            bool bankId,
            bool plannedPaymentsRefs,
            bool transactionsRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bankId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> accountNumber = const Value.absent(),
                Value<int> currentBalanceRial = const Value.absent(),
                Value<bool> includeInFreeBalance = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                bankId: bankId,
                title: title,
                ownerName: ownerName,
                accountNumber: accountNumber,
                currentBalanceRial: currentBalanceRial,
                includeInFreeBalance: includeInFreeBalance,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bankId,
                required String title,
                Value<String?> ownerName = const Value.absent(),
                Value<String?> accountNumber = const Value.absent(),
                Value<int> currentBalanceRial = const Value.absent(),
                Value<bool> includeInFreeBalance = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                bankId: bankId,
                title: title,
                ownerName: ownerName,
                accountNumber: accountNumber,
                currentBalanceRial: currentBalanceRial,
                includeInFreeBalance: includeInFreeBalance,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bankId = false,
                plannedPaymentsRefs = false,
                transactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (plannedPaymentsRefs) db.plannedPayments,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bankId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bankId,
                            referencedTable: $$AccountsTableReferences
                                ._bankIdTable(db),
                            referencedColumn: $$AccountsTableReferences
                                ._bankIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (plannedPaymentsRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          PlannedPayment
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._plannedPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).plannedPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({
        bool bankId,
        bool plannedPaymentsRefs,
        bool transactionsRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String title,
  required int iconCode,
  required String colorHex,
  required String type,
  Value<bool> isDefault,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<int> iconCode,
  Value<String> colorHex,
  Value<String> type,
  Value<bool> isDefault,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlannedPaymentsTable, List<PlannedPayment>>
  _plannedPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.plannedPayments,
    aliasName: 'categories__id__planned_payments__category_id',
  );

  $$PlannedPaymentsTableProcessedTableManager get plannedPaymentsRefs {
    final manager = $$PlannedPaymentsTableTableManager(
      $_db,
      $_db.plannedPayments,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _plannedPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> plannedPaymentsRefs(
    Expression<bool> Function($$PlannedPaymentsTableFilterComposer f) f,
  ) {
    final $$PlannedPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plannedPayments,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.plannedPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  Expression<T> plannedPaymentsRefs<T extends Object>(
    Expression<T> Function($$PlannedPaymentsTableAnnotationComposer a) f,
  ) {
    final $$PlannedPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plannedPayments,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.plannedPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool plannedPaymentsRefs,
            bool transactionsRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                title: title,
                iconCode: iconCode,
                colorHex: colorHex,
                type: type,
                isDefault: isDefault,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int iconCode,
                required String colorHex,
                required String type,
                Value<bool> isDefault = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                title: title,
                iconCode: iconCode,
                colorHex: colorHex,
                type: type,
                isDefault: isDefault,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({plannedPaymentsRefs = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (plannedPaymentsRefs) db.plannedPayments,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (plannedPaymentsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          PlannedPayment
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._plannedPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).plannedPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool plannedPaymentsRefs, bool transactionsRefs})
    >;
typedef $$PlannedPaymentsTableCreateCompanionBuilder =
    PlannedPaymentsCompanion Function({
      Value<int> id,
      required int accountId,
      Value<int?> categoryId,
      required String title,
      required int amountRial,
      required DateTime dueDate,
      Value<String> status,
      Value<bool> isRecurring,
    });
typedef $$PlannedPaymentsTableUpdateCompanionBuilder =
    PlannedPaymentsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<int?> categoryId,
      Value<String> title,
      Value<int> amountRial,
      Value<DateTime> dueDate,
      Value<String> status,
      Value<bool> isRecurring,
    });

final class $$PlannedPaymentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlannedPaymentsTable, PlannedPayment> {
  $$PlannedPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('planned_payments__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('planned_payments__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlannedPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedPaymentsTable> {
  $$PlannedPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountRial => $composableBuilder(
    column: $table.amountRial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlannedPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedPaymentsTable> {
  $$PlannedPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountRial => $composableBuilder(
    column: $table.amountRial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlannedPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedPaymentsTable> {
  $$PlannedPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amountRial => $composableBuilder(
    column: $table.amountRial,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlannedPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlannedPaymentsTable,
          PlannedPayment,
          $$PlannedPaymentsTableFilterComposer,
          $$PlannedPaymentsTableOrderingComposer,
          $$PlannedPaymentsTableAnnotationComposer,
          $$PlannedPaymentsTableCreateCompanionBuilder,
          $$PlannedPaymentsTableUpdateCompanionBuilder,
          (PlannedPayment, $$PlannedPaymentsTableReferences),
          PlannedPayment,
          PrefetchHooks Function({bool accountId, bool categoryId})
        > {
  $$PlannedPaymentsTableTableManager(
    _$AppDatabase db,
    $PlannedPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> amountRial = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
              }) => PlannedPaymentsCompanion(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                title: title,
                amountRial: amountRial,
                dueDate: dueDate,
                status: status,
                isRecurring: isRecurring,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                Value<int?> categoryId = const Value.absent(),
                required String title,
                required int amountRial,
                required DateTime dueDate,
                Value<String> status = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
              }) => PlannedPaymentsCompanion.insert(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                title: title,
                amountRial: amountRial,
                dueDate: dueDate,
                status: status,
                isRecurring: isRecurring,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlannedPaymentsTable, PlannedPayment>(table),
                  $$PlannedPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$PlannedPaymentsTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$PlannedPaymentsTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$PlannedPaymentsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$PlannedPaymentsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlannedPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlannedPaymentsTable,
      PlannedPayment,
      $$PlannedPaymentsTableFilterComposer,
      $$PlannedPaymentsTableOrderingComposer,
      $$PlannedPaymentsTableAnnotationComposer,
      $$PlannedPaymentsTableCreateCompanionBuilder,
      $$PlannedPaymentsTableUpdateCompanionBuilder,
      (PlannedPayment, $$PlannedPaymentsTableReferences),
      PlannedPayment,
      PrefetchHooks Function({bool accountId, bool categoryId})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required int accountId,
      Value<int?> categoryId,
      required int amountRial,
      required String type,
      required DateTime occurredAt,
      Value<String?> rawSmsText,
      Value<bool> isCategorized,
      Value<String?> description,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<int?> categoryId,
      Value<int> amountRial,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String?> rawSmsText,
      Value<bool> isCategorized,
      Value<String?> description,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('transactions__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountRial => $composableBuilder(
    column: $table.amountRial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawSmsText => $composableBuilder(
    column: $table.rawSmsText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCategorized => $composableBuilder(
    column: $table.isCategorized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountRial => $composableBuilder(
    column: $table.amountRial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawSmsText => $composableBuilder(
    column: $table.rawSmsText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCategorized => $composableBuilder(
    column: $table.isCategorized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountRial => $composableBuilder(
    column: $table.amountRial,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawSmsText => $composableBuilder(
    column: $table.rawSmsText,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCategorized => $composableBuilder(
    column: $table.isCategorized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool accountId, bool categoryId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> amountRial = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> rawSmsText = const Value.absent(),
                Value<bool> isCategorized = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                amountRial: amountRial,
                type: type,
                occurredAt: occurredAt,
                rawSmsText: rawSmsText,
                isCategorized: isCategorized,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                Value<int?> categoryId = const Value.absent(),
                required int amountRial,
                required String type,
                required DateTime occurredAt,
                Value<String?> rawSmsText = const Value.absent(),
                Value<bool> isCategorized = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                amountRial: amountRial,
                type: type,
                occurredAt: occurredAt,
                rawSmsText: rawSmsText,
                isCategorized: isCategorized,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, Transaction>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$TransactionsTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$TransactionsTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$TransactionsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$TransactionsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool accountId, bool categoryId})
    >;
typedef $$SalaryPeriodsTableCreateCompanionBuilder =
    SalaryPeriodsCompanion Function({
      Value<int> id,
      Value<int> startDayOfMonth,
      Value<bool> isActive,
    });
typedef $$SalaryPeriodsTableUpdateCompanionBuilder =
    SalaryPeriodsCompanion Function({
      Value<int> id,
      Value<int> startDayOfMonth,
      Value<bool> isActive,
    });

class $$SalaryPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $SalaryPeriodsTable> {
  $$SalaryPeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDayOfMonth => $composableBuilder(
    column: $table.startDayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalaryPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $SalaryPeriodsTable> {
  $$SalaryPeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDayOfMonth => $composableBuilder(
    column: $table.startDayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalaryPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalaryPeriodsTable> {
  $$SalaryPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startDayOfMonth => $composableBuilder(
    column: $table.startDayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$SalaryPeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalaryPeriodsTable,
          SalaryPeriod,
          $$SalaryPeriodsTableFilterComposer,
          $$SalaryPeriodsTableOrderingComposer,
          $$SalaryPeriodsTableAnnotationComposer,
          $$SalaryPeriodsTableCreateCompanionBuilder,
          $$SalaryPeriodsTableUpdateCompanionBuilder,
          (
            SalaryPeriod,
            BaseReferences<_$AppDatabase, $SalaryPeriodsTable, SalaryPeriod>,
          ),
          SalaryPeriod,
          PrefetchHooks Function()
        > {
  $$SalaryPeriodsTableTableManager(_$AppDatabase db, $SalaryPeriodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalaryPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalaryPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalaryPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> startDayOfMonth = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => SalaryPeriodsCompanion(
                id: id,
                startDayOfMonth: startDayOfMonth,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> startDayOfMonth = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => SalaryPeriodsCompanion.insert(
                id: id,
                startDayOfMonth: startDayOfMonth,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalaryPeriodsTable, SalaryPeriod>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SalaryPeriodsTable,
                    SalaryPeriod
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalaryPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalaryPeriodsTable,
      SalaryPeriod,
      $$SalaryPeriodsTableFilterComposer,
      $$SalaryPeriodsTableOrderingComposer,
      $$SalaryPeriodsTableAnnotationComposer,
      $$SalaryPeriodsTableCreateCompanionBuilder,
      $$SalaryPeriodsTableUpdateCompanionBuilder,
      (
        SalaryPeriod,
        BaseReferences<_$AppDatabase, $SalaryPeriodsTable, SalaryPeriod>,
      ),
      SalaryPeriod,
      PrefetchHooks Function()
    >;
typedef $$SmsTemplatesTableCreateCompanionBuilder =
    SmsTemplatesCompanion Function({
      Value<int> id,
      required int bankId,
      required String patternName,
      required String regex,
      Value<int> amountGroupIndex,
      Value<int?> balanceGroupIndex,
      Value<String> withdrawKeyword,
      Value<String> depositKeyword,
    });
typedef $$SmsTemplatesTableUpdateCompanionBuilder =
    SmsTemplatesCompanion Function({
      Value<int> id,
      Value<int> bankId,
      Value<String> patternName,
      Value<String> regex,
      Value<int> amountGroupIndex,
      Value<int?> balanceGroupIndex,
      Value<String> withdrawKeyword,
      Value<String> depositKeyword,
    });

final class $$SmsTemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $SmsTemplatesTable, SmsTemplate> {
  $$SmsTemplatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BanksTable _bankIdTable(_$AppDatabase db) =>
      db.banks.createAlias('sms_templates__bank_id__banks__id');

  $$BanksTableProcessedTableManager get bankId {
    final $_column = $_itemColumn<int>('bank_id')!;

    final manager = $$BanksTableTableManager(
      $_db,
      $_db.banks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bankIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SmsTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $SmsTemplatesTable> {
  $$SmsTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patternName => $composableBuilder(
    column: $table.patternName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regex => $composableBuilder(
    column: $table.regex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountGroupIndex => $composableBuilder(
    column: $table.amountGroupIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceGroupIndex => $composableBuilder(
    column: $table.balanceGroupIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get withdrawKeyword => $composableBuilder(
    column: $table.withdrawKeyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get depositKeyword => $composableBuilder(
    column: $table.depositKeyword,
    builder: (column) => ColumnFilters(column),
  );

  $$BanksTableFilterComposer get bankId {
    final $$BanksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bankId,
      referencedTable: $db.banks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BanksTableFilterComposer(
            $db: $db,
            $table: $db.banks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SmsTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SmsTemplatesTable> {
  $$SmsTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patternName => $composableBuilder(
    column: $table.patternName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regex => $composableBuilder(
    column: $table.regex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountGroupIndex => $composableBuilder(
    column: $table.amountGroupIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceGroupIndex => $composableBuilder(
    column: $table.balanceGroupIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get withdrawKeyword => $composableBuilder(
    column: $table.withdrawKeyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get depositKeyword => $composableBuilder(
    column: $table.depositKeyword,
    builder: (column) => ColumnOrderings(column),
  );

  $$BanksTableOrderingComposer get bankId {
    final $$BanksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bankId,
      referencedTable: $db.banks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BanksTableOrderingComposer(
            $db: $db,
            $table: $db.banks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SmsTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmsTemplatesTable> {
  $$SmsTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patternName => $composableBuilder(
    column: $table.patternName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get regex =>
      $composableBuilder(column: $table.regex, builder: (column) => column);

  GeneratedColumn<int> get amountGroupIndex => $composableBuilder(
    column: $table.amountGroupIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceGroupIndex => $composableBuilder(
    column: $table.balanceGroupIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get withdrawKeyword => $composableBuilder(
    column: $table.withdrawKeyword,
    builder: (column) => column,
  );

  GeneratedColumn<String> get depositKeyword => $composableBuilder(
    column: $table.depositKeyword,
    builder: (column) => column,
  );

  $$BanksTableAnnotationComposer get bankId {
    final $$BanksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bankId,
      referencedTable: $db.banks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BanksTableAnnotationComposer(
            $db: $db,
            $table: $db.banks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SmsTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SmsTemplatesTable,
          SmsTemplate,
          $$SmsTemplatesTableFilterComposer,
          $$SmsTemplatesTableOrderingComposer,
          $$SmsTemplatesTableAnnotationComposer,
          $$SmsTemplatesTableCreateCompanionBuilder,
          $$SmsTemplatesTableUpdateCompanionBuilder,
          (SmsTemplate, $$SmsTemplatesTableReferences),
          SmsTemplate,
          PrefetchHooks Function({bool bankId})
        > {
  $$SmsTemplatesTableTableManager(_$AppDatabase db, $SmsTemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bankId = const Value.absent(),
                Value<String> patternName = const Value.absent(),
                Value<String> regex = const Value.absent(),
                Value<int> amountGroupIndex = const Value.absent(),
                Value<int?> balanceGroupIndex = const Value.absent(),
                Value<String> withdrawKeyword = const Value.absent(),
                Value<String> depositKeyword = const Value.absent(),
              }) => SmsTemplatesCompanion(
                id: id,
                bankId: bankId,
                patternName: patternName,
                regex: regex,
                amountGroupIndex: amountGroupIndex,
                balanceGroupIndex: balanceGroupIndex,
                withdrawKeyword: withdrawKeyword,
                depositKeyword: depositKeyword,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bankId,
                required String patternName,
                required String regex,
                Value<int> amountGroupIndex = const Value.absent(),
                Value<int?> balanceGroupIndex = const Value.absent(),
                Value<String> withdrawKeyword = const Value.absent(),
                Value<String> depositKeyword = const Value.absent(),
              }) => SmsTemplatesCompanion.insert(
                id: id,
                bankId: bankId,
                patternName: patternName,
                regex: regex,
                amountGroupIndex: amountGroupIndex,
                balanceGroupIndex: balanceGroupIndex,
                withdrawKeyword: withdrawKeyword,
                depositKeyword: depositKeyword,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SmsTemplatesTable, SmsTemplate>(table),
                  $$SmsTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bankId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bankId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bankId,
                        referencedTable: $$SmsTemplatesTableReferences
                            ._bankIdTable(db),
                        referencedColumn: $$SmsTemplatesTableReferences
                            ._bankIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SmsTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SmsTemplatesTable,
      SmsTemplate,
      $$SmsTemplatesTableFilterComposer,
      $$SmsTemplatesTableOrderingComposer,
      $$SmsTemplatesTableAnnotationComposer,
      $$SmsTemplatesTableCreateCompanionBuilder,
      $$SmsTemplatesTableUpdateCompanionBuilder,
      (SmsTemplate, $$SmsTemplatesTableReferences),
      SmsTemplate,
      PrefetchHooks Function({bool bankId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BanksTableTableManager get banks =>
      $$BanksTableTableManager(_db, _db.banks);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$PlannedPaymentsTableTableManager get plannedPayments =>
      $$PlannedPaymentsTableTableManager(_db, _db.plannedPayments);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$SalaryPeriodsTableTableManager get salaryPeriods =>
      $$SalaryPeriodsTableTableManager(_db, _db.salaryPeriods);
  $$SmsTemplatesTableTableManager get smsTemplates =>
      $$SmsTemplatesTableTableManager(_db, _db.smsTemplates);
}
