ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('od_animal:getPet', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT pet FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		if result[1].pet ~= nil then
			cb(result[1].pet)
		else
			cb('')
		end
	end)
end)

RegisterServerEvent('od_animal:petDied')
AddEventHandler('od_animal:petDied', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('UPDATE users SET pet = "(NULL)" WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	})
end)

RegisterServerEvent('od_animal:consumePetFood')
AddEventHandler('od_animal:consumePetFood', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem('croquettes', 1)
end)

ESX.RegisterServerCallback('od_animal:buyPet', function(source, cb, pet, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	if price == 0 then
		print('od_animal: %s attempted to buy an invalid pet!')
		cb(false)
	end

	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
		MySQL.Async.execute('UPDATE users SET pet = @pet WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier,
			['@pet'] = pet
		}, function(rowsChanged)
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_bought', ESX.Math.GroupDigits(price)))
			cb(true)
		end)
	else
		TriggerClientEvent('esx:showNotification', source, _U('your_poor'))
		cb(false)
	end
end)
