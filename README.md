# raportowanie_zdarzen_niebezpiecznych

## Weryfikacja tożsamości

Aplikacja weryfikuje tożsamość zgłaszającego poprzez e-mail służbowy.

Ze względu na przewidywalną strukturę domeny adresu e-mail (*@*.s*.gov.pl) proces weryfikacji będzie odbywał się poprzez zebranie od zgłaszającego jego służbowego adresu sprawdzenie czy adres jest zgodny z tymi przyznawany pracownikom sądów oraz wysłanie do niego wiadomości na ten adres w celu weryfikacji.

## Przyjmowanie informacji

Przyjmowanie indywidualnych zgłoszeń od kuratorów sądowych o zaistniałych niebezpiecznych sytuacjach w których się znaleźli podczas wykonywania obowiązków służbowych.

Potrzebne informacje:

 dane osobowe:
- imię i nazwisko
- email służbowy
- nazwa sądu i zespołu kuratorskiego
- numer telefonu (opcjonalnie)
- status kuratora (zawodowy / społeczny)
    
- data zdarzenia
- miejsce zdarzenia
kategoria zdarzenia:
- napaść na kuratora (słowna)
- napaść na kuratora (fizyczna)
- pogryzienie przez zwierzę
- zniszczenie ubrania
- zniszczenie mienia (np uszkodzenie samochodu)
- wypadek podczas wykonywania czynności służbowych (np złamanie, zasłabnięcie)
- zarażenie się chorobą
- groźby pod adresem kuratora
- inne (pole do wypełnienia)

- opis zdarzenia
- załączenie ewentualnych fotografii

Aplikacja zbiera potrzebne informacje i przechowa je w bazie danych firebase oraz wyśle powiadomienie o przyjętym zgłoszeniu do administratora serwisu.

## Generowanie raportów Panel administracyjny

Aplikacja posiada interfejs administratora przez który daje on dostęp zalogowanemu użytkownikowi do interfejsu przeglądania zgłoszeń i generowania raportów.

Aplikacja generuje raporty pojedynczych zgłoszeń według szablonu w celu łatwego rozpatrzenia zgłoszeń oraz przekazywania tych danych.

Aplikacja generuje raporty ilości zgłoszeń w okresie określonym przez administratora w interfejsie administracyjnym według szablonu.


# interfejs użytkownika
![image](https://github.com/user-attachments/assets/954e4314-17f1-4ceb-8897-19c3aa0a2fe0)

# panel administratora
## logowanie
![image](https://github.com/user-attachments/assets/8d8757db-bcb9-4eaa-9e32-eb4884c932a0)
## panel
![image](https://github.com/user-attachments/assets/94e31fcb-f413-4b91-aa30-e0d9399f76ef)
![image](https://github.com/user-attachments/assets/647f4d7d-a98e-4d8a-90aa-3502924361fe)
![image](https://github.com/user-attachments/assets/640d0120-e017-4154-b401-4fd4e321aaa3)
![image](https://github.com/user-attachments/assets/e253703f-2225-4ab2-9bb1-1b32dbc4d314)

![image](https://github.com/user-attachments/assets/e5a6dee6-f1c4-4ef3-916f-7e5e5ce2c642)
![image](https://github.com/user-attachments/assets/725a8a46-4c17-4575-97fe-1a4d6186da4e)


