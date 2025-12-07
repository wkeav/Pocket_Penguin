# penguin_app/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from .views import CurrentUserGameProfile

class CurrentUserGameProfile(APIView):
    def get(self, request):
        return Response({"msg": "dummy"})
