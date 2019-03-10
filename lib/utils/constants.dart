import 'package:flutter/material.dart';
import 'package:darulfikr/utils/social_icon_icons.dart';

const String appName = "Даруль Фикр";
const String version = "2.0.0";
const String siteUrl = "dmuradz.beget.tech";

const String logo =
    "https://pp.userapi.com/c836735/v836735739/2913f/2dCJY1Mm8kU.jpg";
const List<Map<String, int>> sections = [
  {
    "Все статьи": 12,
  },
  {"Начинающим": 395},
  {"Интервью": 397},
  {"Мусульманка": 396},
  {
    "Акыда": 47,
  },
  {
    "Фикх": 3,
  },
  {
    "Коран": 8,
  },
  {
    "Хадис": 9,
  },
  {
    "Адаб": 4,
  },
  {
    "История": 53,
  },
  {
    "Манхадж": 7,
  },
  {
    "Опровержения": 54,
  },
  {
    "Усуль": 11,
  }
];

const List<Map<String, int>> audioCategory = [
  {
    "Акыда": 24,
  },
  {"История": 29},
  {"Исламская литература": 687},
  {
    "Коран": 26,
  },
  {"Манхадж": 30},
  {"Тасаввуф": 28},
  {"Фикх": 25},
  {"Хадис": 27},
]; //аудиокатегории

const List<Map<String, String>> favoriteSections = [
  {"Статьи": ""},
  {
    "Видео": "video",
  },
  {"Книги": "book"},
];
const List fonts = ['PT Sans', 'Droid Sans', 'Serif', "Open Sans"];
const List<Map<dynamic, String>> social = [
  {
    Icon(SocialIcon.facebook_official): "https://www.facebook.com/darulfikrweb/"
  },
  {Icon(SocialIcon.instagram): "https://www.instagram.com/darulfikr/"},
  {Icon(SocialIcon.vkontakte): "https://vk.com/darulfikr"},
  {Icon(SocialIcon.send): "https://t.me/darulfikr"},
  {Icon(SocialIcon.youtube): "https://www.youtube.com/darulfikrmedia"}
];

const _orangePrimaryValue = 0xFFE76C35;
const MaterialColor accent = const MaterialColor(
  _orangePrimaryValue,
  const <int, Color>{
    50: const Color(0xFF356ce7),
    100: const Color(0xFF356ce7),
    200: const Color(0xFF356ce7),
    300: const Color(0xFF356ce7),
    400: const Color(0xFF356ce7),
    500: const Color(_orangePrimaryValue),
    600: const Color(0xFF356ce7),
    700: const Color(0xFF000000),
    800: const Color(0xFF000000),
    900: const Color(0xFF000000),
  },
);
const String helpHTML =
    '<!-- .entry-header --><div class="post_content_wrap"><p style="text-align: justify;"><span style="font-family: '
    "times new roman"
    ', times, serif; font-size: 20px;"><strong>«Даруль-Фикр»</strong> — Исламский образовательный портал, целью которого является распространение истинного вероубеждения Ахлю-Сунна валь-Джамаа.&nbsp;</span><span style="font-family: '
    "times new roman"
    ', times, serif; font-size: 20px;"> Вся работа портала основана на безвозмездной работе добровольцев.</span></p><p style="text-align: justify;"><span style="font-family: '
    "times new roman"
    ', times, serif; font-size: 20px;"> Мы никак не связаны с политическими, национальными или националистическими движениями, партиями или организациями.</span></p><p style="text-align: justify;"><span style="font-family: '
    "times new roman"
    ',times, serif; font-size: 20px;"> Помимо сайта www.darulfikr.ru, организован Издательский дом <strong>«Даруль-Фикр»</strong>, который занимается переводом текстов, тиражированием и распространением печатной продукции.</span></p><p style="text-align: center;"><span style="font-family: '
    "times new roman"
    ', times, serif; font-size: 20px;"> Мы нуждаемся в ваших дуа за работников портала и издательского дома.&nbsp;Желающие помочь материально могут перечислить деньги просто пополнив счет телефона (Билайн):<strong>\t\r\n+7 963 400 34 43 </strong></span></p>';
