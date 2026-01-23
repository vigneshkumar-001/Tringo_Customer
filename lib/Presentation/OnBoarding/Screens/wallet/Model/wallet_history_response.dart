class WalletHistoryResponse {
  final bool status;
  final int code;
  final WalletHistoryData data;

  WalletHistoryResponse({
    required this.status,
    required this.code,
    required this.data,
  });

  factory WalletHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WalletHistoryResponse(
      status: json['status'] == true,
      code: (json['code'] as num).toInt(),
      data: WalletHistoryData.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'code': code,
    'data': data.toJson(),
  };
}

class WalletHistoryData {
  final Wallet wallet;
  final Paging paging;
  final Counts counts;
  final List<Section> sections;

  WalletHistoryData({
    required this.wallet,
    required this.paging,
    required this.counts,
    required this.sections,
  });

  factory WalletHistoryData.fromJson(Map<String, dynamic> json) {
    return WalletHistoryData(
      wallet: Wallet.fromJson(
        (json['wallet'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      paging: Paging.fromJson(
        (json['paging'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      counts: Counts.fromJson(
        (json['counts'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      sections: ((json['sections'] as List?) ?? const [])
          .map((e) => Section.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'wallet': wallet.toJson(),
    'paging': paging.toJson(),
    'counts': counts.toJson(),
    'sections': sections.map((e) => e.toJson()).toList(),
  };
}

class Wallet {
  final String uid;
  final num tcoinBalance; // use num because server may send int/double
  final num rate;

  Wallet({
    required this.uid,
    required this.tcoinBalance,
    required this.rate,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      uid: (json['uid'] ?? '').toString(),
      tcoinBalance: json['tcoinBalance'] is num ? (json['tcoinBalance'] as num) : 0,
      rate: json['rate'] is num ? (json['rate'] as num) : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'tcoinBalance': tcoinBalance,
    'rate': rate,
  };
}

class Paging {
  final int take;
  final int skip;
  final int total;

  Paging({
    required this.take,
    required this.skip,
    required this.total,
  });

  factory Paging.fromJson(Map<String, dynamic> json) {
    return Paging(
      take: (json['take'] is num) ? (json['take'] as num).toInt() : 0,
      skip: (json['skip'] is num) ? (json['skip'] as num).toInt() : 0,
      total: (json['total'] is num) ? (json['total'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'take': take,
    'skip': skip,
    'total': total,
  };
}

class Counts {
  final int all;
  final int rewards;
  final int sent;
  final int received;
  final int withdraw;

  Counts({
    required this.all,
    required this.rewards,
    required this.sent,
    required this.received,
    required this.withdraw,
  });

  factory Counts.fromJson(Map<String, dynamic> json) {
    int _i(dynamic v) => (v is num) ? v.toInt() : 0;

    return Counts(
      all: _i(json['all']),
      rewards: _i(json['rewards']),
      sent: _i(json['sent']),
      received: _i(json['received']),
      withdraw: _i(json['withdraw']),
    );
  }

  Map<String, dynamic> toJson() => {
    'all': all,
    'rewards': rewards,
    'sent': sent,
    'received': received,
    'withdraw': withdraw,
  };
}

class Section {
  final String dayKey; // "TODAY"
  final String dayLabel; // "Today"
  final List<WalletHistoryItem> items;

  Section({
    required this.dayKey,
    required this.dayLabel,
    required this.items,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      dayKey: (json['dayKey'] ?? '').toString(),
      dayLabel: (json['dayLabel'] ?? '').toString(),
      items: ((json['items'] as List?) ?? const [])
          .map((e) => WalletHistoryItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'dayKey': dayKey,
    'dayLabel': dayLabel,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class WalletHistoryItem {
  final String id;
  final String timeLabel; // "4:29 PM"
  final String dateLabel; // "23 Jan 2026"
  final String title; // "Signup Bonus"
  final String subtitle; // "4:29 PM"
  final num amountTcoin; // 10
  final String amountSign; // "+"
  final String badgeLabel; // "Received"
  final String badgeType; // "RECEIVED" (can make enum later)

  WalletHistoryItem({
    required this.id,
    required this.timeLabel,
    required this.dateLabel,
    required this.title,
    required this.subtitle,
    required this.amountTcoin,
    required this.amountSign,
    required this.badgeLabel,
    required this.badgeType,
  });

  factory WalletHistoryItem.fromJson(Map<String, dynamic> json) {
    return WalletHistoryItem(
      id: (json['id'] ?? '').toString(),
      timeLabel: (json['timeLabel'] ?? '').toString(),
      dateLabel: (json['dateLabel'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      amountTcoin: (json['amountTcoin'] is num) ? (json['amountTcoin'] as num) : 0,
      amountSign: (json['amountSign'] ?? '').toString(),
      badgeLabel: (json['badgeLabel'] ?? '').toString(),
      badgeType: (json['badgeType'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timeLabel': timeLabel,
    'dateLabel': dateLabel,
    'title': title,
    'subtitle': subtitle,
    'amountTcoin': amountTcoin,
    'amountSign': amountSign,
    'badgeLabel': badgeLabel,
    'badgeType': badgeType,
  };
}
