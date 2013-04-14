DELETE FROM party.party WHERE id = 'p1';
DELETE FROM party.party WHERE id = 'p2';
DELETE FROM address.address WHERE id = 'a1';
DELETE FROM address.address WHERE id = 'a2';
DELETE FROM party.party_role WHERE party_id = 'p1';

INSERT INTO address.address (id, description) VALUES ('a1', 'viale delle terme di caracalla, 1');
INSERT INTO address.address (id, description) VALUES ('a2', 'piazza navona, 12/3');

INSERT INTO party.party (id, type_code, "name", address_id) VALUES ('p1', 'nonNaturalPerson', 'Buy&Sell LTD.', 'a1');
INSERT INTO party.party (id, type_code, "name", last_name, address_id) VALUES ('p2', 'naturalPerson', 'John', 'Smith', 'a2');

INSERT INTO party.party_role(party_id, type_code) VALUES ('p1', 'lodgingAgent');